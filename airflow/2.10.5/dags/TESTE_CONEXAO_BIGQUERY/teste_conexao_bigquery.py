import pendulum
from datetime import timedelta
from airflow import DAG
from airflow.providers.google.cloud.operators.bigquery import BigQueryInsertJobOperator

tz = pendulum.timezone("America/Sao_Paulo")

default_args = {
    "owner": "jprtenorio",
    "start_date": pendulum.datetime(year=2025, month=3, day=27).astimezone(tz),
    "retry_delay": timedelta(minutes=1),
    "retries": 1,
}

with DAG(
    dag_id='teste_conexao_bigquery',
    description='Teste de Conexão do Conector Airflow com o BigQuery',
    schedule_interval=None,
    default_args=default_args,
    catchup=False,
    tags=['teste'],
) as dag:

    testar_conexao = BigQueryInsertJobOperator(
        task_id='executa_query_teste',
        configuration={
            "query": {
                "query": "SELECT CURRENT_DATE() AS data_atual",
                "useLegacySql": False,
            }
        },
        gcp_conn_id='google_cloud_default',
    )
