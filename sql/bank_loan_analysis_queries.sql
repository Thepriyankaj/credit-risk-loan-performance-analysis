/* =========================================
   BANK LOAN ANALYSIS - SQL QUERIES
   Author: Thepriyankaj
   Database: bank_loan_db
   Tool: MySQL Workbench
   ========================================= */

USE bank_loan_db;

/* =========================================
   SECTION 1 - KPI QUERIES
   ========================================= */

-- -----------------------------------------------
-- KPI 1: Total Loan Applications
-- -----------------------------------------------
SELECT COUNT(id) AS Total_Loan_Applications
FROM financial_loan;

-- -----------------------------------------------
-- KPI 2: Total Funded Amount
-- -----------------------------------------------
SELECT SUM(loan_amount) AS Total_Funded_Amount
FROM financial_loan;

-- -----------------------------------------------
-- KPI 3: Total Amount Received
-- -----------------------------------------------
SELECT SUM(total_payment) AS Total_Amount_Received
FROM financial_loan;

-- -----------------------------------------------
-- KPI 4: Average Interest Rate
-- -----------------------------------------------
SELECT ROUND(AVG(int_rate), 2) AS Avg_Interest_Rate
FROM financial_loan;

-- -----------------------------------------------
-- KPI 5: Average DTI (Debt-To-Income Ratio)
-- -----------------------------------------------
SELECT ROUND(AVG(dti) * 100, 2) AS Avg_DTI
FROM financial_loan;

-- -----------------------------------------------
-- KPI 6: Month-over-Month Applications (MoM)
-- -----------------------------------------------
SELECT
    DATE_FORMAT(issue_date,'%Y-%m') AS Month,
    COUNT(id) AS Total_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Amount_Received
FROM financial_loan
GROUP BY DATE_FORMAT(issue_date,'%Y-%m')
ORDER BY Month;

-- -----------------------------------------------
-- KPI 7: MTD (Month-To-Date) Applications
-- Example MTD Analysis for Dec-2021
-- -----------------------------------------------
SELECT 
    COUNT(id) AS MTD_Total_Applications,
    SUM(loan_amount) AS MTD_Total_Funded_Amount,
    SUM(total_payment) AS MTD_Total_Amount_Received
FROM financial_loan
WHERE MONTH(issue_date) = 12
  AND YEAR(issue_date) = 2021;

-- -----------------------------------------------
-- KPI 8: PMTD (Previous Month-To-Date)
-- Example PMTD Analysis for Nov-2021
-- -----------------------------------------------
SELECT 
    COUNT(id) AS PMTD_Total_Applications,
    SUM(loan_amount) AS PMTD_Total_Funded_Amount,
    SUM(total_payment) AS PMTD_Total_Amount_Received
FROM financial_loan
WHERE MONTH(issue_date) = 11
  AND YEAR(issue_date) = 2021;
  
-- -----------------------------------------------
-- KPI 9: MoM Growth Rate (Applications)
-- -----------------------------------------------
SELECT 
    Month_Name,
    Total_Applications,
    LAG(Total_Applications) OVER (ORDER BY Month) AS Prev_Month,
    ROUND((Total_Applications - LAG(Total_Applications) 
    OVER (ORDER BY Month)) / LAG(Total_Applications) 
    OVER (ORDER BY Month) * 100, 2) AS MoM_Growth_Pct
FROM (
    SELECT 
        MONTH(issue_date) AS Month,
        MONTHNAME(issue_date) AS Month_Name,
        COUNT(id) AS Total_Applications
    FROM financial_loan
    GROUP BY MONTH(issue_date), MONTHNAME(issue_date)
) AS monthly_data
ORDER BY Month;


/* =========================================
   SECTION 2 - LOAN PERFORMANCE ANALYSIS
   ========================================= */

-- -----------------------------------------------
-- LP 1: Total Applications by Loan Status
-- -----------------------------------------------
SELECT 
    loan_status,
    COUNT(id) AS Total_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Amount_Received
FROM financial_loan
GROUP BY loan_status
ORDER BY Total_Applications DESC;

-- -----------------------------------------------
-- LP 2: Good Loan vs Bad Loan - Total Applications
-- -----------------------------------------------
SELECT
    good_bad_loan,
    COUNT(id) AS Total_Applications,
    ROUND(COUNT(id) * 100.0 / (SELECT COUNT(id) FROM financial_loan), 2) AS Percentage
FROM financial_loan
GROUP BY good_bad_loan;

-- -----------------------------------------------
-- LP 3: Good Loan vs Bad Loan - Funded & Received
-- -----------------------------------------------
SELECT
    good_bad_loan,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Amount_Received,
    ROUND(SUM(total_payment) - SUM(loan_amount), 2) AS Net_Profit_Loss
FROM financial_loan
GROUP BY good_bad_loan;

-- -----------------------------------------------
-- LP 4: Loan Performance by Term
-- -----------------------------------------------
SELECT
    term,
    COUNT(id) AS Total_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Amount_Received,
    ROUND(AVG(int_rate), 2) AS Avg_Interest_Rate,
	ROUND(AVG(dti),2) AS Avg_DTI
FROM financial_loan
GROUP BY term
ORDER BY term;

-- -----------------------------------------------
-- LP 5: Monthly Loan Performance Trend
-- -----------------------------------------------
SELECT
    DATE_FORMAT(issue_date, '%Y-%m') AS Month,
    COUNT(id) AS Total_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Amount_Received,
    ROUND(SUM(total_payment) - SUM(loan_amount), 2) AS Net_Amount
FROM financial_loan
GROUP BY DATE_FORMAT(issue_date, '%Y-%m')
ORDER BY Month;

-- -----------------------------------------------
-- LP 6: Loan Performance by Grade
-- -----------------------------------------------
SELECT
    grade,
    COUNT(id) AS Total_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    ROUND(AVG(int_rate), 2) AS Avg_Interest_Rate,
    SUM(CASE WHEN good_bad_loan = 'Bad Loan' THEN 1 ELSE 0 END) AS Bad_Loans,
    ROUND(SUM(CASE WHEN good_bad_loan = 'Bad Loan' THEN 1 ELSE 0 END) * 100.0 / COUNT(id), 2) AS Bad_Loan_Rate
FROM financial_loan
GROUP BY grade
ORDER BY grade;

-- -----------------------------------------------
-- LP 7: Loan Performance by Purpose
-- -----------------------------------------------
SELECT
    purpose,
    COUNT(id) AS Total_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(CASE WHEN good_bad_loan = 'Bad Loan' THEN 1 ELSE 0 END) AS Bad_Loans,
    ROUND(SUM(CASE WHEN good_bad_loan = 'Bad Loan' THEN 1 ELSE 0 END) * 100.0 / COUNT(id), 2) AS Bad_Loan_Rate
FROM financial_loan
GROUP BY purpose
ORDER BY Bad_Loan_Rate DESC;


/* =========================================
   SECTION 3 - RISK ANALYSIS
   ========================================= */

-- -----------------------------------------------
-- RA 1: Risk Distribution by DTI Category
-- -----------------------------------------------
SELECT
    dti_risk_category,
    COUNT(id) AS Total_Applications,
    ROUND(COUNT(id) * 100.0 / (SELECT COUNT(id) FROM financial_loan), 2) AS Percentage,
    SUM(loan_amount) AS Total_Funded_Amount,
    ROUND(AVG(int_rate), 2) AS Avg_Interest_Rate,
    SUM(CASE WHEN good_bad_loan = 'Bad Loan' THEN 1 ELSE 0 END) AS Bad_Loans,
    ROUND(SUM(CASE WHEN good_bad_loan = 'Bad Loan' THEN 1 ELSE 0 END) * 100.0 / COUNT(id), 2) AS Bad_Loan_Rate
FROM financial_loan
GROUP BY dti_risk_category
ORDER BY Bad_Loan_Rate DESC;

-- -----------------------------------------------
-- RA 2: Risk Analysis by Grade & Sub Grade
-- -----------------------------------------------
SELECT
    grade,
    sub_grade,
    COUNT(id) AS Total_Applications,
    ROUND(AVG(int_rate), 2) AS Avg_Interest_Rate,
    ROUND(AVG(dti) * 100, 2) AS Avg_DTI,
    SUM(CASE WHEN good_bad_loan = 'Bad Loan' THEN 1 ELSE 0 END) AS Bad_Loans,
    ROUND(SUM(CASE WHEN good_bad_loan = 'Bad Loan' THEN 1 ELSE 0 END) * 100.0 / COUNT(id), 2) AS Bad_Loan_Rate
FROM financial_loan
GROUP BY grade, sub_grade
ORDER BY grade, sub_grade;

-- -----------------------------------------------
-- RA 3: Interest Rate by Risk Category
-- -----------------------------------------------
SELECT
    dti_risk_category,
    grade,
    ROUND(AVG(int_rate), 2) AS Avg_Interest_Rate,
    ROUND(MIN(int_rate), 2) AS Min_Interest_Rate,
    ROUND(MAX(int_rate), 2) AS Max_Interest_Rate,
    COUNT(id) AS Total_Applications
FROM financial_loan
GROUP BY dti_risk_category, grade
ORDER BY dti_risk_category, grade;

-- -----------------------------------------------
-- RA 4: High Risk Loans Analysis
-- (Bad Loans with High DTI and High Interest Rate)
-- -----------------------------------------------
SELECT
    grade,
    purpose,
    COUNT(id) AS Total_High_Risk_Loans,
    ROUND(AVG(int_rate), 2) AS Avg_Interest_Rate,
    ROUND(AVG(dti) * 100, 2) AS Avg_DTI,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Received,
    ROUND(SUM(total_payment) - SUM(loan_amount), 2) AS Net_Loss
FROM financial_loan
WHERE good_bad_loan = 'Bad Loan'
  AND dti_risk_category = 'High Risk'
GROUP BY grade, purpose
ORDER BY Net_Loss ASC;

-- -----------------------------------------------
-- RA 5: Loan Size vs Risk
-- -----------------------------------------------
SELECT
    loan_size_category,
    COUNT(id) AS Total_Applications,
    ROUND(AVG(int_rate), 2) AS Avg_Interest_Rate,
    SUM(CASE WHEN good_bad_loan = 'Bad Loan' THEN 1 ELSE 0 END) AS Bad_Loans,
    ROUND(SUM(CASE WHEN good_bad_loan = 'Bad Loan' THEN 1 ELSE 0 END) * 100.0 / COUNT(id), 2) AS Bad_Loan_Rate,
    SUM(loan_amount) AS Total_Funded_Amount
FROM financial_loan
GROUP BY loan_size_category
ORDER BY Bad_Loan_Rate DESC;

-- -----------------------------------------------
-- RA 6: Verification Status vs Risk
-- -----------------------------------------------
SELECT
    verification_status,
    COUNT(id) AS Total_Applications,
    SUM(CASE WHEN good_bad_loan = 'Bad Loan' THEN 1 ELSE 0 END) AS Bad_Loans,
    ROUND(SUM(CASE WHEN good_bad_loan = 'Bad Loan' THEN 1 ELSE 0 END) * 100.0 / COUNT(id), 2) AS Bad_Loan_Rate,
    ROUND(AVG(int_rate), 2) AS Avg_Interest_Rate,
    ROUND(AVG(dti) * 100, 2) AS Avg_DTI
FROM financial_loan
GROUP BY verification_status
ORDER BY Bad_Loan_Rate DESC;


/* =========================================
   SECTION 4 - BORROWER ANALYSIS
   ========================================= */

-- -----------------------------------------------
-- BA 1: Loan Applications by Employment Length
-- -----------------------------------------------
SELECT
    emp_length,
    COUNT(id) AS Total_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    ROUND(AVG(int_rate), 2) AS Avg_Interest_Rate,
    ROUND(AVG(annual_income),2) AS Avg_Annual_Income,
    SUM(CASE WHEN good_bad_loan = 'Bad Loan' THEN 1 ELSE 0 END) AS Bad_Loans,
    ROUND(SUM(CASE WHEN good_bad_loan = 'Bad Loan' THEN 1 ELSE 0 END) * 100.0 / COUNT(id), 2) AS Bad_Loan_Rate
FROM financial_loan
GROUP BY emp_length
ORDER BY Total_Applications DESC;

-- -----------------------------------------------
-- BA 2: Loan Applications by Home Ownership
-- -----------------------------------------------
SELECT
    home_ownership,
    COUNT(id) AS Total_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    ROUND(AVG(int_rate), 2) AS Avg_Interest_Rate,
    ROUND(AVG(loan_amount),2) AS Avg_Loan_Amount,
    SUM(CASE WHEN good_bad_loan = 'Bad Loan' THEN 1 ELSE 0 END) AS Bad_Loans,
    ROUND(SUM(CASE WHEN good_bad_loan = 'Bad Loan' THEN 1 ELSE 0 END) * 100.0 / COUNT(id), 2) AS Bad_Loan_Rate
FROM financial_loan
GROUP BY home_ownership
ORDER BY Total_Applications DESC;

-- -----------------------------------------------
-- BA 3: Loan Applications by Income Category
-- -----------------------------------------------
SELECT
    income_category,
    COUNT(id) AS Total_Applications,
    ROUND(AVG(annual_income), 2) AS Avg_Annual_Income,
    SUM(loan_amount) AS Total_Funded_Amount,
    ROUND(AVG(int_rate), 2) AS Avg_Interest_Rate,
    ROUND(AVG(dti) * 100, 2) AS Avg_DTI,
    ROUND(AVG(loan_amount),2) AS Avg_Loan_Amount,
    SUM(CASE WHEN good_bad_loan = 'Bad Loan' THEN 1 ELSE 0 END) AS Bad_Loans,
    ROUND(SUM(CASE WHEN good_bad_loan = 'Bad Loan' THEN 1 ELSE 0 END) * 100.0 / COUNT(id), 2) AS Bad_Loan_Rate
FROM financial_loan
GROUP BY income_category
ORDER BY Avg_Annual_Income DESC;

-- -----------------------------------------------
-- BA 4: Loan Purpose by Borrower Profile
-- -----------------------------------------------

SELECT
    purpose,
    COUNT(id) AS Total_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    ROUND(AVG(annual_income),2) AS Avg_Annual_Income
FROM financial_loan
GROUP BY purpose
ORDER BY Total_Applications DESC;

-- -----------------------------------------------
-- BA 5: Borrower Risk Profile
-- (High Income but Still Defaulted)
-- -----------------------------------------------
SELECT
    income_category,
    COUNT(id) AS Bad_Loan_Count,
    ROUND(AVG(annual_income), 2) AS Avg_Annual_Income,
    ROUND(AVG(loan_amount), 2) AS Avg_Loan_Amount,
    ROUND(AVG(dti) * 100, 2) AS Avg_DTI,
    ROUND(AVG(int_rate), 2) AS Avg_Interest_Rate
FROM financial_loan
WHERE good_bad_loan = 'Bad Loan'
GROUP BY income_category
ORDER BY Avg_Annual_Income DESC;

-- -----------------------------------------------
-- BA 6: Employment Length vs Loan Default
-- -----------------------------------------------
SELECT
    emp_length,
    COUNT(id) AS Total_Applications,
    SUM(CASE WHEN good_bad_loan = 'Bad Loan' THEN 1 ELSE 0 END) AS Bad_Loans,
    ROUND(SUM(CASE WHEN good_bad_loan = 'Bad Loan' THEN 1 ELSE 0 END) * 100.0 / COUNT(id), 2) AS Bad_Loan_Rate,
    ROUND(AVG(annual_income), 2) AS Avg_Annual_Income,
    ROUND(AVG(loan_amount), 2) AS Avg_Loan_Amount
FROM financial_loan
GROUP BY emp_length
ORDER BY Bad_Loan_Rate DESC;


/* =========================================
   SECTION 5 - GEOGRAPHIC ANALYSIS
   ========================================= */

-- -----------------------------------------------
-- GA 1: Loan Applications by State
-- -----------------------------------------------
SELECT
    address_state,
    COUNT(id) AS Total_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Amount_Received,
    ROUND(AVG(int_rate), 2) AS Avg_Interest_Rate,
    SUM(CASE WHEN good_bad_loan = 'Bad Loan' THEN 1 ELSE 0 END) AS Bad_Loans,
    ROUND(SUM(CASE WHEN good_bad_loan = 'Bad Loan' THEN 1 ELSE 0 END) * 100.0 / COUNT(id), 2) AS Bad_Loan_Rate
FROM financial_loan
GROUP BY address_state
ORDER BY Total_Applications DESC;

-- -----------------------------------------------
-- GA 2: Top 10 States by Loan Applications
-- -----------------------------------------------
SELECT
    address_state,
    COUNT(id) AS Total_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    ROUND(AVG(int_rate), 2) AS Avg_Interest_Rate,
    SUM(CASE WHEN good_bad_loan = 'Bad Loan' THEN 1 ELSE 0 END) AS Bad_Loans,
    ROUND(SUM(CASE WHEN good_bad_loan = 'Bad Loan' THEN 1 ELSE 0 END) * 100.0 / COUNT(id), 2) AS Bad_Loan_Rate
FROM financial_loan
GROUP BY address_state
ORDER BY Total_Applications DESC
LIMIT 10;

-- -----------------------------------------------
-- GA 3: Top 10 States by Bad Loan Rate
-- (Minimum 100 applications for significance)
-- -----------------------------------------------
SELECT
    address_state,
    COUNT(id) AS Total_Applications,
    SUM(CASE WHEN good_bad_loan = 'Bad Loan' THEN 1 ELSE 0 END) AS Bad_Loans,
    ROUND(SUM(CASE WHEN good_bad_loan = 'Bad Loan' THEN 1 ELSE 0 END) * 100.0 / COUNT(id), 2) AS Bad_Loan_Rate,
    ROUND(AVG(int_rate), 2) AS Avg_Interest_Rate,
    ROUND(AVG(dti) * 100, 2) AS Avg_DTI
FROM financial_loan
GROUP BY address_state
HAVING COUNT(id) >= 100
ORDER BY Bad_Loan_Rate DESC
LIMIT 10;

-- -----------------------------------------------
-- GA 4: State wise Funded Amount & Recovery Rate
-- -----------------------------------------------
SELECT
    address_state,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Amount_Received,
    ROUND(SUM(total_payment) * 100.0 / SUM(loan_amount), 2) AS Recovery_Rate_Pct,
    COUNT(id) AS Total_Applications
FROM financial_loan
GROUP BY address_state
ORDER BY Recovery_Rate_Pct DESC
LIMIT 10;

-- -----------------------------------------------
-- GA 5: Geographic Risk Heatmap Data
-- (State, Risk Category, Applications)
-- -----------------------------------------------
SELECT
    address_state,
    dti_risk_category,
    COUNT(id) AS Total_Applications,
    ROUND(AVG(int_rate), 2) AS Avg_Interest_Rate,
    SUM(CASE WHEN good_bad_loan = 'Bad Loan' THEN 1 ELSE 0 END) AS Bad_Loans,
    ROUND(SUM(CASE WHEN good_bad_loan = 'Bad Loan' THEN 1 ELSE 0 END) * 100.0 / COUNT(id), 2) AS Bad_Loan_Rate
FROM financial_loan
GROUP BY address_state, dti_risk_category
ORDER BY address_state, Bad_Loan_Rate DESC;

-- -----------------------------------------------
-- GA 6: Bottom 10 States by Applications
-- (Lowest Loan Penetration States)
-- -----------------------------------------------
SELECT
    address_state,
    COUNT(id) AS Total_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    ROUND(AVG(int_rate), 2) AS Avg_Interest_Rate,
    SUM(CASE WHEN good_bad_loan = 'Bad Loan' THEN 1 ELSE 0 END) AS Bad_Loans,
    ROUND(SUM(CASE WHEN good_bad_loan = 'Bad Loan' THEN 1 ELSE 0 END) * 100.0 / COUNT(id), 2) AS Bad_Loan_Rate
FROM financial_loan
GROUP BY address_state
ORDER BY Total_Applications ASC
LIMIT 10;

-- -----------------------------------------------
-- GA 7: State-wise Average Loan Size
-- (Minimum 100 applications for statistical significance)
-- -----------------------------------------------
SELECT
    address_state,
    ROUND(AVG(loan_amount),2) AS Avg_Loan_Size,
    COUNT(id) AS Total_Applications
FROM financial_loan
GROUP BY address_state
HAVING COUNT(id) >= 100
ORDER BY Avg_Loan_Size DESC;
