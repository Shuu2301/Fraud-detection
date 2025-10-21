CREATE OR REPLACE VIEW "Finance Analytics".transactions_analytics AS
SELECT 
    -- Transaction Facts
    ft.transaction_id,
    ft.amount,
    ft.use_chip,
    ft.errors,
    ft.is_fraud,
    ft.fraud_label_source,
    ft.transaction_count,
    
    -- Date Dimension
    dd.full_date AS trans_date,
    dd."day" AS day_of_month,
    dd."week" AS week_of_year,
    dd."month" AS month_of_year,
    dd."quarter" AS quarter_of_year,
    dd."year" AS year_value,
    dd.day_of_week,
    dd.is_weekend,
    
    -- User Dimension
    du.client_id,
    du.user_sk,
    du.birth_year,
    du.gender,
    du.yearly_income,
    du.total_debt,
    du.credit_score,
    du.num_credit_cards,
    du.latitude AS user_latitude,
    du.longitude AS user_longitude,
    du.user_segment,
    
    -- Card Dimension
    dc.card_id,
    dc.card_sk,
    dc.card_brand,
    dc.card_type,
    dc.credit_limit,
    dc.acct_open_date,
    dc.has_chip,
    dc.card_on_dark_web,
    
    -- Merchant Dimension
    dm.merchant_id,
    dm.merchant_sk,
    dm.merchant_type AS merchant_category,
    dm.merchant_city,
    dm.merchant_state,
    dm.merchant_zip,
    
    -- MCC Dimension
    mcc.mcc,
    mcc.merchant_type AS mcc_category
    
FROM s3.fact_transactions ft
LEFT JOIN s3.dim_date dd ON ft.date_sk = dd.date_sk
LEFT JOIN s3.dim_user du ON ft.user_sk = du.user_sk
LEFT JOIN s3.dim_card dc ON ft.card_sk = dc.card_sk
LEFT JOIN s3.dim_merchant dm ON ft.merchant_sk = dm.merchant_sk
LEFT JOIN s3.dim_mcc mcc ON ft.mcc_sk = mcc.mcc;