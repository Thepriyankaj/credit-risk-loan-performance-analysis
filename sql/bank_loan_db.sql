CREATE DATABASE bank_loan_db;
USE bank_loan_db;

CREATE TABLE financial_loan (
    id                    INT PRIMARY KEY,
    address_state         VARCHAR(50),
    emp_length            VARCHAR(50),
    emp_title             VARCHAR(100),
    grade                 VARCHAR(5),
    home_ownership        VARCHAR(50),
    issue_date            DATE,
    last_credit_pull_date DATE,
    last_payment_date     DATE,
    loan_status           VARCHAR(50),
    next_payment_date     DATE,
    purpose               VARCHAR(50),
    sub_grade             VARCHAR(10),
    term                  VARCHAR(20),
    verification_status   VARCHAR(50),
    annual_income         FLOAT,
    dti                   FLOAT,
    installment           FLOAT,
    int_rate              FLOAT,
    loan_amount           INT,
    total_acc             INT,
    total_payment         INT,
    good_bad_loan         VARCHAR(20),
    income_category       VARCHAR(20),
    loan_size_category    VARCHAR(20),
    dti_risk_category     VARCHAR(20)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 9.7/Uploads/financial_loan_cleaned.csv'
INTO TABLE financial_loan
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, address_state, emp_length, emp_title, grade, home_ownership,
@issue_date, @last_credit_pull_date, @last_payment_date,
loan_status, @next_payment_date, purpose, sub_grade, term,
verification_status, annual_income, dti, installment, int_rate,
loan_amount, total_acc, total_payment, good_bad_loan,
income_category, loan_size_category, dti_risk_category)
SET
issue_date            = STR_TO_DATE(@issue_date, '%d-%m-%Y'),
last_credit_pull_date = STR_TO_DATE(@last_credit_pull_date, '%d-%m-%Y'),
last_payment_date     = STR_TO_DATE(@last_payment_date, '%d-%m-%Y'),
next_payment_date     = STR_TO_DATE(@next_payment_date, '%d-%m-%Y');

SELECT COUNT(*) FROM financial_loan;

SELECT * FROM financial_loan LIMIT 5;