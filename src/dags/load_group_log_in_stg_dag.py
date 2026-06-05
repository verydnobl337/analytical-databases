from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.vertica.hooks.vertica import VerticaHook

from datetime import datetime


def load_group_log_in_stg(): 
    hook = VerticaHook(vertica_conn_id='vertica_conn')

    conn = hook.get_conn()
    cursor = conn.cursor()

    cursor.execute("""
                COPY VT26052617E774__STAGING.group_log
                FROM LOCAL '/data/group_log.csv'
                DELIMITER ','
                """)
    
    cursor.close()
    conn.close()

with DAG(
    dag_id='load_group_log_in_stg',
    start_date=datetime(2022, 7, 13),
    catchup=False
) as dag:
    
    download_group_log_in_stg = PythonOperator(
        task_id='download_group_log_in_st',
        python_callable=load_group_log_in_stg
    )

    download_group_log_in_stg
