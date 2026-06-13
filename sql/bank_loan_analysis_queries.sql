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
-- Example MTD Analysis for Nov-2021
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

