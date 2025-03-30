import pendulum
from datetime import timedelta
from pathlib import Path
from airflow import DAG
from airflow.providers.google.cloud.operators.bigquery import BigQueryInsertJobOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator

tz = pendulum.timezone("America/Sao_Paulo")

default_args = {
    "owner": "jprtenorio",
    "start_date": pendulum.datetime(2025, 3, 27, tz=tz),
    "retries": 1,
    "retry_delay": timedelta(minutes=1),
}

sql_path = Path(__file__).parent / "sql_files" / "insert_coincap_assets.sql"
with open(sql_path, "r") as file:
    sql_query = file.read()

with DAG(
    dag_id="sz_api_coincap_bnb",
    description="Transforma dados da tabela RZ e popula tabela SZ no BigQuery",
    default_args=default_args,
    schedule_interval=None,
    catchup=False,
    tags=["coincap", "bigquery", "etl", "assets", "bnb", "sz"],
) as dag:

    transformar_dados_sz = BigQueryInsertJobOperator(
        task_id="transformar_e_inserir_sz",
        configuration={
            "query": {
                "query": sql_query,
                "useLegacySql": False,
            }
        },
        gcp_conn_id="google_cloud_default",
    )

    acionar_dag_cz = TriggerDagRunOperator(
        task_id="acionar_dag_cz",
        trigger_dag_id="cz_api_coincap_bnb",
        wait_for_completion=False
    )

    transformar_dados_sz >> acionar_dag_cz
