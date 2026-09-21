from datetime import datetime

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.amazon.aws.hooks.s3 import S3Hook

from config import AWS_CONN_ID, DAG_START_DATE, LOCAL_FILE, S3_BUCKET, S3_FILE


def load_group_log_from_s3():
    """Download the source CSV from S3 to the local Airflow filesystem."""
    s3_hook = S3Hook(aws_conn_id=AWS_CONN_ID)
    s3_hook.get_key(key=S3_FILE, bucket_name=S3_BUCKET).download_file(LOCAL_FILE)


with DAG(
    dag_id="load_group_log_from_s3",
    start_date=datetime.fromisoformat(DAG_START_DATE),
    catchup=False,
) as dag:
    download_group_log = PythonOperator(
        task_id="download_group_log",
        python_callable=load_group_log_from_s3,
    )
