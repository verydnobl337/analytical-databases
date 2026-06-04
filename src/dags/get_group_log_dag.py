from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.amazon.aws.hooks.s3 import S3Hook

from datetime import datetime


aws_conn_id = 's3_connection'
bucket_name = 'sprint6'
file_name = 'group_log.csv'
local_path = '/data/group_log.csv'

def load_group_log_from_s3():
    s3_hook = S3Hook(aws_conn_id=aws_conn_id)

    s3_hook.get_key(
        key=file_name,
        bucket_name=bucket_name
    ).download_file(local_path)


with DAG( 
    dag_id='load_group_log_from_s3',
    start_date=datetime(2022, 7, 13),
    catchup=False,
) as dag:
    
    download_group_log = PythonOperator(
        task_id='dowload_group_log',
        python_callable=load_group_log_from_s3
    )

    download_group_log