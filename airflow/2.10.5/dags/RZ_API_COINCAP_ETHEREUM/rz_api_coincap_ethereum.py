import pendulum, requests, json
from datetime import timedelta
from pathlib import Path
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.google.cloud.operators.bigquery import BigQueryInsertJobOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator

tz = pendulum.timezone("America/Sao_Paulo")

default_args = {
    "owner": "jprtenorio",
    "start_date": pendulum.datetime(2025, 3, 27, tz=tz),
    "retries": 1,
    "retry_delay": timedelta(minutes=1),
}

PROJECT_ID = "inspired-nomad-455114-k3"
DATASET_ID = "rz_api_coincap"
TABLE_ID = "rz_coincap_ethereum"

sql_path = Path(__file__).parent / "sql_files" / "insert_coincap_assets.sql"
secrets_path = Path(__file__).resolve().parents[2] / "secrets_config.json"

with open(secrets_path) as f:
    secrets = json.load(f)

API_KEY = secrets["COINCAP_API_KEY"]

def gerar_sql_insert_coincap(**context):
    def escape_sql_string(value):
        if value is None:
            return "NULL"
        return "'" + str(value).replace("'", "\\'") + "'"
    
    url = "https://api.coincap.io/v2/assets/ethereum/history?interval=h1&limit=2000"
    headers = {"Authorization": f"Bearer {API_KEY}"}
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    data = response.json()["data"]

    valores = []
    for item in data:
        linha = "STRUCT(" + ", ".join([
            f"'ethereum' AS id",
            f"{escape_sql_string(item.get('priceUsd'))} AS priceUsd",
            f"{item.get('time')} AS time",
            f"{escape_sql_string(item.get('date'))} AS date"
        ]) + ")"
        valores.append(linha)

    raw_sql = sql_path.read_text()
    sql_final = raw_sql.format(values=",\n".join(valores))

    context['ti'].xcom_push(key='sql_coincap', value=sql_final)

with DAG(
    dag_id="rz_api_coincap_ethereum",
    description="Carrega dados da CoinCap Assets sobre Ethereum direto pro BigQuery",
    default_args=default_args,
    schedule_interval="40 * * * *",
    catchup=False,
    tags=["coincap", "bigquery", "etl", "assets", "ethereum", "rz"],
) as dag:

    gerar_sql_coincap = PythonOperator(
        task_id="gerar_sql_coincap",
        python_callable=gerar_sql_insert_coincap,
        provide_context=True
    )

    inserir_bigquery = BigQueryInsertJobOperator(
        task_id="inserir_dados_no_bigquery",
        configuration={
            "query": {
                "query": "{{ ti.xcom_pull(task_ids='gerar_sql_coincap', key='sql_coincap') }}",
                "useLegacySql": False
            }
        },
        gcp_conn_id="google_cloud_default",
    )

    acionar_dag_sz = TriggerDagRunOperator(
        task_id="acionar_dag_sz",
        trigger_dag_id="sz_api_coincap_ethereum",
        wait_for_completion=False
    )

    gerar_sql_coincap >> inserir_bigquery >> acionar_dag_sz
