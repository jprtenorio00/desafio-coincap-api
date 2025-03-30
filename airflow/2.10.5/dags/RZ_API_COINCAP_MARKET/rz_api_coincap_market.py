import pendulum, requests, json, time
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
TABLE_ID = "rz_coincap_market"

sql_path = Path(__file__).parent / "sql_files" / "insert_coincap_assets.sql"
secrets_path = Path(__file__).resolve().parents[2] / "secrets_config.json"

with open(secrets_path) as f:
    secrets = json.load(f)

API_KEY = secrets["COINCAP_API_KEY"]

def parse_float(value):
    try:
        return str(float(value))
    except (ValueError, TypeError):
        return "NULL"

def gerar_sql_insert_coincap(**context):
    def escape_sql_string(value):
        if value is None:
            return "NULL"
        return "'" + str(value).replace("'", "\\'") + "'"
    
    ids = ["bitcoin", "ethereum", "binance-coin"]
    headers = {"Authorization": f"Bearer {API_KEY}"}
    valores = []

    for crypto_id in ids:
        url = f"https://api.coincap.io/v2/assets/{crypto_id}/markets"
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        markets = response.json().get("data", [])

        for item in markets:
            linha = "STRUCT(" + ", ".join([
                f"{escape_sql_string(crypto_id)} AS cryptoId",
                f"{escape_sql_string(item.get('exchangeId'))} AS exchangeId",
                f"{escape_sql_string(item.get('baseSymbol'))} AS baseSymbol",
                f"{escape_sql_string(item.get('baseId'))} AS baseId",
                f"{escape_sql_string(item.get('quoteSymbol'))} AS quoteSymbol",
                f"{escape_sql_string(item.get('quoteId'))} AS quoteId",
                f"{parse_float(item.get('priceUsd'))} AS priceUsd",
                f"{parse_float(item.get('volumeUsd24Hr'))} AS volumeUsd24Hr",
                f"{parse_float(item.get('volumePercent'))} AS volumePercent"
            ]) + ")"
            valores.append(linha)

        time.sleep(30)

    raw_sql = sql_path.read_text()
    sql_final = raw_sql.format(values=",\n".join(valores))
    context['ti'].xcom_push(key='sql_coincap', value=sql_final)    

with DAG(
    dag_id="rz_api_coincap_market",
    description="Carrega dados da CoinCap Assets Market direto pro BigQuery",
    default_args=default_args,
    schedule_interval="10 * * * *",
    catchup=False,
    tags=["coincap", "bigquery", "etl", "assets", "market", "rz"],
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
        trigger_dag_id="sz_api_coincap_market",
        wait_for_completion=False
    )

    gerar_sql_coincap >> inserir_bigquery >> acionar_dag_sz
