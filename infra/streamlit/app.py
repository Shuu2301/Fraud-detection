import streamlit as st
import time
from pyspark.sql import SparkSession
from pyspark.sql.functions import *
import plotly.express as px

# Page configuration
st.set_page_config(
    page_title="Finance Analytics Dashboard",
    layout="wide"
)

MINIO_ACCESS_KEY = "minioadmin"
MINIO_SECRET_KEY = "minioadmin123"
MINIO_ENDPOINT = "http://minio:9000"

# Initialize Spark session (cached for performance)
@st.cache_resource
def get_spark_session():
    return SparkSession.builder \
        .appName("FinanceDashboard") \
        .config("spark.jars.packages", "io.delta:delta-spark_2.12:3.1.0,org.apache.hadoop:hadoop-aws:3.3.4") \
        .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension") \
        .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog") \
        .config("spark.hadoop.fs.s3a.endpoint", MINIO_ENDPOINT) \
        .config("spark.hadoop.fs.s3a.access.key", MINIO_ACCESS_KEY) \
        .config("spark.hadoop.fs.s3a.secret.key", MINIO_SECRET_KEY) \
        .config("spark.hadoop.fs.s3a.path.style.access", "true") \
        .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
        .getOrCreate()

spark = get_spark_session()

# Data loading functions
@st.cache_data(ttl=60)
def get_total_users():
    try:
        df = spark.read.format("delta").load("s3a://rootdb/users/")
        return df.count()
    except Exception as e:
        st.error(f"Error loading users: {e}")
        return None

@st.cache_data(ttl=60)
def get_total_transactions():
    try:
        df = spark.read.format("delta").load("s3a://rootdb/transactions/")
        return df.count()
    except Exception as e:
        st.error(f"Error loading transactions: {e}")
        return None

@st.cache_data(ttl=300)
def get_transaction_volume_over_time():
    try:
        df = spark.read.format("delta").load("s3a://rootdb/transactions/")
        # Extract date from trans_date for daily grouping
        trends = df.withColumn("date", to_date("trans_date")) \
                   .groupBy("date").count().orderBy("date").toPandas()
        return trends
    except Exception as e:
        st.error(f"Error loading transaction volume: {e}")
        return None

@st.cache_data(ttl=300)
def get_top_10_customers():
    try:
        df = spark.read.format("delta").load("s3a://rootdb/transactions/")
        # Use client_id as customer identifier
        top = df.groupBy("client_id").count().orderBy(desc("count")).limit(10).toPandas()
        # Ensure sorted by count descending
        top = top.sort_values(by='count', ascending=False)
        # Convert client_id to string to treat as categorical
        top['client_id'] = top['client_id'].astype(str)
        return top
    except Exception as e:
        st.error(f"Error loading top customers: {e}")
        return None

# Sidebar for page selection
page = st.sidebar.radio("Select Dashboard", ["Overview", "Dashboards"])

# Dashboard title
st.title("Finance Analytics Dashboard")

if page == "Overview":
    # Get fresh data
    total_users = get_total_users()
    total_transactions = get_total_transactions()

    # Display metrics in columns
    col1, col2 = st.columns(2)

    with col1:
        if isinstance(total_users, int):
            st.metric("Total Users", f"{total_users:,}")
        else:
            st.metric("Total Users", "Error")

    with col2:
        if isinstance(total_transactions, int):
            st.metric("Total Transactions", f"{total_transactions:,}")
        else:
            st.metric("Total Transactions", "Error")

    # Status messages
    if isinstance(total_users, int) and total_users > 0:
        st.success("Successfully connected")
    elif isinstance(total_users, int) and total_users == 0:
        st.warning("No user data found. Check your Delta Lake table.")
    else:
        st.error("Failed to load user data")

elif page == "Dashboards":
    st.header("Transaction Volume Over Time")
    trends = get_transaction_volume_over_time()
    if trends is not None and not trends.empty:
        fig = px.line(trends, x="date", y="count", title="Daily Transaction Volume")
        st.plotly_chart(fig, use_container_width=True)
    else:
        st.warning("No transaction volume data available.")

    st.header("Top 10 Customers by Transaction Count")
    customers = get_top_10_customers()
    if customers is not None and not customers.empty:
        # Sort by count to ensure proper order from top to bottom
        customers = customers.sort_values(by='count', ascending=True)
        fig = px.bar(customers, x="count", y="client_id", orientation='h', title="Top 10 Customers")
        fig.update_layout(yaxis={'type': 'category'})
        st.plotly_chart(fig, use_container_width=True)
    else:
        st.warning("No customer data available.")

# Auto-refresh
time.sleep(5)
st.rerun()