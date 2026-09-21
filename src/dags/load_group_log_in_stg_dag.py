from datetime import datetime

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.vertica.hooks.vertica import VerticaHook

from config import DAG_START_DATE, LOCAL_FILE, STAGING_TABLE, VERTICA_CONN_ID


def load_group_log_in_stg():
    """Load the downloaded CSV file into the Vertica staging table."""
    hook = VerticaHook(vertica_conn_id=VERTICA_CONN_ID)
    conn = hook.get_conn()
    cursor = conn.cursor()

    try:
        cursor.execute(
            f"""
            COPY {STAGING_TABLE}
            FROM LOCAL '{LOCAL_FILE}'
            DELIMITER ','
            """
        )
    finally:
        cursor.close()
        conn.close()


with DAG(
    dag_id="load_group_log_in_stg",
    start_date=datetime.fromisoformat(DAG_START_DATE),
    catchup=False,
) as dag:
    load_group_log = PythonOperator(
        task_id="load_group_log_in_stg",
        python_callable=load_group_log_in_stg,
    )
