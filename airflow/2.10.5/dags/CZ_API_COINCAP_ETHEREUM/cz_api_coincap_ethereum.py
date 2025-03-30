import pendulum
from datetime import timedelta
from pathlib import Path
from airflow import DAG
from airflow.providers.google.cloud.operators.bigquery import BigQueryInsertJobOperator

tz = pendulum.timezone("America/Sao_Paulo")

default_args = {
    "owner": "jprtenorio",
    "start_date": pendulum.datetime(2025, 3, 27, tz=tz),
    "retries": 1,
    "retry_delay": timedelta(minutes=1),
}

PROJECT_ID = "inspired-nomad-455114-k3"
DATASET_ID = "cz_api_coincap"
TABLE_ID = "cz_coincap_ethereum"

sql_path = Path(__file__).parent / "sql_files" / "insert_coincap_assets.sql"

with DAG(
    dag_id="cz_api_coincap_ethereum",
    description="Enriquecimento dos dados com data de consulta a partir da SZ",
    default_args=default_args,
    schedule_interval=None,
    catchup=False,
    tags=["coincap", "bigquery", "etl", "assets", "ethereum", "cz"],
) as dag:

    inserir_dados_cz = BigQueryInsertJobOperator(
        task_id="inserir_dados_cz",
        configuration={
            "query": {
                "query": sql_path.read_text(),
                "useLegacySql": False,
            }
        },
        gcp_conn_id="google_cloud_default",
    )

    inserir_dados_cz
