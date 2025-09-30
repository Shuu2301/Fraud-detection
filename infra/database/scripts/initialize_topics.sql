-- Dummy value to initialize the kafka topics

INSERT INTO users (client_id, current_age, retirement_age, birth_year, birth_month, gender, address, latitude, longitude, per_capita_income, yearly_income, total_debt, credit_score, num_credit_cards) 
VALUES (999999999999, 30, 65, 1993, 1, 'Other', 'Dummy Address', 0.000000, 0.000000, 0.00, 0.00, 0.00, 500, 0);


INSERT INTO mcc_codes (mcc, merchant_type) 
VALUES (999999999999, 'Dummy Merchant Type');


INSERT INTO cards (card_id, client_id, card_brand, card_type, card_number, expires, cvv, has_chip, num_cards_issued, credit_limit, acct_open_date, year_pin_last_changed, card_on_dark_web) 
VALUES (999999999999, 999999999999, 'Dummy', 'Dummy', '9999999999999999', '2099-12-31', '999', 'No', 0, 0.00, '2000-01-01', 2000, 'No');


INSERT INTO transactions (transaction_id, trans_date, client_id, card_id, amount, use_chip, merchant_id, mcc, merchant_city, merchant_state, zip, errors) 
VALUES (999999999999, '2000-01-01 00:00:00', 999999999999, 999999999999, 0.00, 'Dummy Transaction', 0, 999999999999, 'Dummy City', 'XX', '00000', 'Dummy record for topic initialization');


INSERT INTO fraud_labels (transaction_id, label) 
VALUES (999999999999, 'No');

DELETE FROM fraud_labels WHERE transaction_id = 999999999999;
DELETE FROM transactions WHERE transaction_id = 999999999999;
DELETE FROM cards WHERE card_id = 999999999999;
DELETE FROM mcc_codes WHERE mcc = 999999999999;
DELETE FROM users WHERE client_id = 999999999999;