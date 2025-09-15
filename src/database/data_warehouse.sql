-- Data Warehouse schema for Finance Analytics (star schema)
-- Grain: one row in fact_transactions = one source transaction

CREATE DATABASE IF NOT EXISTS finance_dw;
USE finance_dw;
-- DIMENSIONS and FACTS translated to Apache Doris (OLAP) DDL

CREATE TABLE dim_date (
    date_sk INT NOT NULL,
    full_date DATE NOT NULL,
    day INT,
    week INT,
    month INT,
    quarter INT,
    year INT,
    day_of_week INT,
    is_weekend TINYINT(1)
)
UNIQUE KEY(date_sk)
DISTRIBUTED BY HASH(date_sk) BUCKETS 8
PROPERTIES("replication_num" = "1");

CREATE TABLE dim_customer (
    client_id BIGINT,                   -- natural key from source
    customer_sk BIGINT,                 -- surrogate (managed by ETL)
    birth_year INT,
    gender VARCHAR(10),
    yearly_income DECIMAL(15,2),
    total_debt DECIMAL(15,2),
    credit_score INT,
    num_credit_cards INT,
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6),
    customer_segment VARCHAR(100)
)
UNIQUE KEY(client_id)
DISTRIBUTED BY HASH(client_id) BUCKETS 8
PROPERTIES("replication_num" = "1");

CREATE TABLE dim_card (
    card_id BIGINT,                     -- natural key from source
    card_sk BIGINT,                     -- surrogate (managed by ETL)
    client_id BIGINT,
    card_brand VARCHAR(50),
    card_type VARCHAR(20),
    credit_limit DECIMAL(15,2),
    acct_open_date DATE,
    has_chip TINYINT(1),
    card_on_dark_web TINYINT(1)
)
UNIQUE KEY(card_id)
DISTRIBUTED BY HASH(card_id) BUCKETS 8
PROPERTIES("replication_num" = "1");

CREATE TABLE dim_merchant (
    merchant_id BIGINT,                   -- natural key from source
    merchant_sk BIGINT,                   -- surrogate (managed by ETL)
    mcc BIGINT,
    merchant_type VARCHAR(100),
    merchant_city VARCHAR(100),
    merchant_state VARCHAR(50),
    merchant_zip VARCHAR(10)
)
UNIQUE KEY(merchant_id)
DISTRIBUTED BY HASH(merchant_id) BUCKETS 8
PROPERTIES("replication_num" = "1");

CREATE TABLE dim_mcc (
    mcc BIGINT,
    merchant_type VARCHAR(100)
)
UNIQUE KEY(mcc)
DISTRIBUTED BY HASH(mcc) BUCKETS 4
PROPERTIES("replication_num" = "1");

CREATE TABLE fact_transactions (
    transaction_id BIGINT,   -- natural key from source
    date_sk INT NOT NULL,
    customer_sk BIGINT,
    card_sk BIGINT,
    merchant_sk BIGINT,
    amount DECIMAL(15,2) NOT NULL,
    use_chip TINYINT(1),
    errors VARCHAR(255),
    is_fraud TINYINT(1) DEFAULT 0,
    fraud_label_source VARCHAR(50),
    transaction_count INT DEFAULT 1
)
UNIQUE KEY(transaction_id)
DISTRIBUTED BY HASH(transaction_id) BUCKETS 16
PROPERTIES("replication_num" = "1");
