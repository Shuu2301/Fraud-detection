#!/bin/bash

# Load environment variables from .env file
if [ -f "$(dirname "$0")/.env" ]; then
    export $(grep -v '^#' "$(dirname "$0")/.env" | xargs)
fi

# Set Airflow UID for proper permissions (if using volume mounts)
export AIRFLOW_UID=$(id -u)

sudo docker compose up -d

sleep 10

sleep 15

# Register MySQL source connector
CONFIG_FILE="$(dirname "$0")/config/register-mysql.json"
if [ ! -f "$CONFIG_FILE" ]; then
    exit 1
fi

curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" \
     localhost:8083/connectors/ \
     -d @"$CONFIG_FILE"

sleep 5

# Find initialize sql file
SQL_FILE="$(dirname "$0")/database/scripts/initialize_topics.sql"
if [ ! -f "$SQL_FILE" ]; then
    exit 1
fi

# Execute the SQL file 
docker exec -i mysql mysql -u root -p${MYSQL_ROOT_PASSWORD} finance < "$SQL_FILE"

sleep 15

# Check if Kafka topics with "finance.finance." prefix exist 
FINANCE_TOPICS=$(docker exec kafka kafka-topics.sh --bootstrap-server localhost:9092 --list | grep "^finance\.finance\." | wc -l)

if [ "$FINANCE_TOPICS" -eq 0 ]; then
    exit 1
fi
