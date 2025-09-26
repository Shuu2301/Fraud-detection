CREATE DATABASE finance;
USE finance;

CREATE TABLE users (
    client_id BIGINT PRIMARY KEY,
    current_age INT,
    retirement_age INT,
    birth_year INT,
    birth_month INT,
    gender ENUM('Male','Female','Other'),
    address VARCHAR(255),
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6),
    per_capita_income DECIMAL(15,2),
    yearly_income DECIMAL(15,2),
    total_debt DECIMAL(15,2),
    credit_score INT,
    num_credit_cards INT
);

CREATE TABLE cards (
    card_id BIGINT PRIMARY KEY,
    client_id BIGINT NOT NULL,
    card_brand VARCHAR(50),
    card_type VARCHAR(20),
    card_number VARCHAR(20) UNIQUE,
    expires DATE,
    cvv CHAR(4),
    has_chip ENUM('Yes','No'),
    num_cards_issued INT,
    credit_limit DECIMAL(15,2),
    acct_open_date DATE,
    year_pin_last_changed YEAR,
    card_on_dark_web ENUM('Yes','No'),

    FOREIGN KEY (client_id) REFERENCES users(client_id)
);

CREATE TABLE mcc_codes (
    mcc BIGINT PRIMARY KEY,
    merchant_type VARCHAR(100) NOT NULL
);

CREATE TABLE transactions (
    transaction_id BIGINT PRIMARY KEY,
    trans_date DATETIME NOT NULL,
    client_id BIGINT NOT NULL,
    card_id BIGINT NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    use_chip VARCHAR(20) NOT NULL,
    merchant_id INT NOT NULL,
    mcc BIGINT NOT NULL,
    merchant_city VARCHAR(100),
    merchant_state VARCHAR(50),
    zip VARCHAR(10),
    errors VARCHAR(255),
    
    FOREIGN KEY (client_id) REFERENCES users(client_id),
    FOREIGN KEY (card_id) REFERENCES cards(card_id),
    FOREIGN KEY (mcc) REFERENCES mcc_codes(mcc)
);

CREATE TABLE fraud_labels (
    transaction_id BIGINT PRIMARY KEY,
    label ENUM('Yes','No') NOT NULL DEFAULT 'No',
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id) ON DELETE CASCADE
);

-- Dummy value to initialize the kafka topics

-- INSERT INTO users (client_id, current_age, retirement_age, birth_year, birth_month, gender, address, latitude, longitude, per_capita_income, yearly_income, total_debt, credit_score, num_credit_cards) 
-- VALUES (999999999999, 30, 65, 1993, 1, 'Other', 'Dummy Address', 0.000000, 0.000000, 0.00, 0.00, 0.00, 500, 0);


-- INSERT INTO mcc_codes (mcc, merchant_type) 
-- VALUES (999999999999, 'Dummy Merchant Type');


-- INSERT INTO cards (card_id, client_id, card_brand, card_type, card_number, expires, cvv, has_chip, num_cards_issued, credit_limit, acct_open_date, year_pin_last_changed, card_on_dark_web) 
-- VALUES (999999999999, 999999999999, 'Dummy', 'Dummy', '9999999999999999', '2099-12-31', '999', 'No', 0, 0.00, '2000-01-01', 2000, 'No');


-- INSERT INTO transactions (transaction_id, trans_date, client_id, card_id, amount, use_chip, merchant_id, mcc, merchant_city, merchant_state, zip, errors) 
-- VALUES (999999999999, '2000-01-01 00:00:00', 999999999999, 999999999999, 0.00, 'Dummy Transaction', 0, 999999999999, 'Dummy City', 'XX', '00000', 'Dummy record for topic initialization');


-- INSERT INTO fraud_labels (transaction_id, label) 
-- VALUES (999999999999, 'No');

-- DELETE FROM fraud_labels WHERE transaction_id = 999999999999;
-- DELETE FROM transactions WHERE transaction_id = 999999999999;
-- DELETE FROM cards WHERE card_id = 999999999999;
-- DELETE FROM mcc_codes WHERE mcc = 999999999999;
-- DELETE FROM users WHERE client_id = 999999999999;