"""
Finance Analytics Pipeline DAG
Monitors and orchestrates the finance data pipeline
"""

from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.sensors.filesystem import FileSensor
import logging

# Default arguments
default_args = {
    'owner': 'finance-team',
    'depends_on_past': False,
    'start_date': datetime(2025, 9, 30),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 2,
    'retry_delay': timedelta(minutes=5),
}

# Create DAG
dag = DAG(
    'finance_pipeline_monitor',
    default_args=default_args,
    description='Finance Analytics Pipeline Monitoring',
    schedule=timedelta(hours=1),  # Run every hour
    catchup=False,
    tags=['finance', 'monitoring', 'cdc'],
)

def check_kafka_topics():
    """Check if Kafka topics are healthy"""
    import subprocess
    try:
        # Check if Kafka topics exist
        result = subprocess.run([
            'docker', 'exec', 'kafka', 
            '/kafka/bin/kafka-topics.sh', 
            '--bootstrap-server', 'kafka:9092', 
            '--list'
        ], capture_output=True, text=True, check=True)
        
        topics = result.stdout.strip().split('\n')
        expected_topics = [
            'finance.finance.transactions',
            'finance.finance.users', 
            'finance.finance.cards',
            'finance.finance.mcc_codes',
            'finance.finance.fraud_labels'
        ]
        
        missing_topics = [topic for topic in expected_topics if topic not in topics]
        
        if missing_topics:
            raise Exception(f"Missing Kafka topics: {missing_topics}")
            
        logging.info(f"All Kafka topics are healthy: {expected_topics}")
        return True
        
    except Exception as e:
        logging.error(f"Kafka health check failed: {e}")
        raise

def check_debezium_connector():
    """Check if Debezium connector is running"""
    import requests
    try:
        response = requests.get('http://connect:8083/connectors/finance-mysql-connector/status')
        if response.status_code == 200:
            status = response.json()
            connector_state = status.get('connector', {}).get('state')
            
            if connector_state != 'RUNNING':
                raise Exception(f"Debezium connector state: {connector_state}")
                
            logging.info("Debezium connector is healthy")
            return True
        else:
            raise Exception(f"Failed to get connector status: {response.status_code}")
            
    except Exception as e:
        logging.error(f"Debezium health check failed: {e}")
        raise

def check_minio_health():
    """Check if MinIO is accessible"""
    import requests
    try:
        response = requests.get('http://minio:9000/minio/health/live')
        if response.status_code == 200:
            logging.info("MinIO is healthy")
            return True
        else:
            raise Exception(f"MinIO health check failed: {response.status_code}")
            
    except Exception as e:
        logging.error(f"MinIO health check failed: {e}")
        raise

# Task 1: Check system health
kafka_health = PythonOperator(
    task_id='check_kafka_health',
    python_callable=check_kafka_topics,
    dag=dag,
)

debezium_health = PythonOperator(
    task_id='check_debezium_health', 
    python_callable=check_debezium_connector,
    dag=dag,
)

minio_health = PythonOperator(
    task_id='check_minio_health',
    python_callable=check_minio_health,
    dag=dag,
)

# Task 2: Check Docker containers
docker_health = BashOperator(
    task_id='check_docker_containers',
    bash_command='''
    echo "Checking Docker container health..."
    docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "(kafka|mysql|connect|minio)"
    ''',
    dag=dag,
)

# Task 3: Log system status
log_status = BashOperator(
    task_id='log_system_status',
    bash_command='''
    echo "Finance Pipeline Health Check"
    echo "Timestamp: $(date)"
    echo "All health checks completed successfully"
    ''',
    dag=dag,
)

# Define task dependencies
[kafka_health, debezium_health, minio_health] >> docker_health >> log_status