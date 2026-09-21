import os


# Runtime configuration is provided by Airflow environment variables.
AWS_CONN_ID = os.environ["ADB_AWS_CONN_ID"]
S3_BUCKET = os.environ["ADB_S3_BUCKET"]
S3_FILE = os.environ["ADB_S3_FILE"]
LOCAL_FILE = os.environ["ADB_LOCAL_FILE"]
VERTICA_CONN_ID = os.environ["ADB_VERTICA_CONN_ID"]
STAGING_TABLE = os.environ["ADB_STAGING_TABLE"]
DAG_START_DATE = os.environ["ADB_DAG_START_DATE"]
