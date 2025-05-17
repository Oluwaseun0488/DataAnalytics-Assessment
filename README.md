# Data Analytics Assessment
Data Analytics Assessment

This repository contains SQL queries for analyzing the adashi_staging database of a financial platform. The analysis revolves around the following business questions:  determining the high value customers, transaction frequency analysis, inactivity detection, and customer lifetime value (CLV) estimation. The queries are done in MySQL and tested on phpMyAdmin, with the output stored in the DataAnalytics-Assessment folder.

Repository Structure

DataAnalytics-Assessment/

│

├── Assessment_Q1.sql

├── Assessment_Q2.sql

├── Assessment_Q3.sql

├── Assessment_Q4.sql

│

└── README.md

Per-Question Explanations

Question 1: High-Value Customers with Multiple Products 

Objective:  Fund both savings accounts and investment plans for customers, then sort them by total deposits.

Approach: 

Identified two CTEs (SavingsPlans, InvestmentPlans) that calculated distinct plan counts and deposits summation of Savings (is_regular_savings=1) and Investments (is_a_fund=1). 

Joined CTEs with users_customuser to fetch customer details and used CONCAT for their full names. 

Converted deposit to Naira (/100) and rounded to 2 decimals. 

Ordered by total deposits descending.

Tables: plans_plan, savings_savingsaccount, users_customuser.

Key Logic: Filter out successful transactions (filter: transaction_status IN (‘success’, ‘successful’, ‘monnify_success’) AND confirmed_amount > 0) and ensure customers have both plan types via JOIN. 

Question 2: Transaction Frequency Analysis

Objective: Group customers based on the frequency of their transactions (High: ≥10, Medium: 3 - 9, Low: ≤2 transactions/month). 

Approach: 

CTE TransactionStats computed the total transactions and months active for each customer using TIMESTAMPDIFF.

CTE Frequency 
Categories assigned transaction frequency categories based on the average transactions per month. 

Distinct count aggregated owner _id and average transactions per category ordered with FIELD. 

Tables: savings_savingsaccount 

Key Logic: Used COUNT(DISTINCT owner _id) for accurate customer counts, and rounded averages to 1 decimal place.  


Question 3: Account inactivity alert  

Objective: Identify savings or investment plans which are active, but have had no transactions in the last 365 days.  

Approach:  
CTE LastTransaction retrieves the latest transaction per plan. 
CTE LastTransaction was joined with plans_plan to find active plans with no recent transactions (is_deleted = 0, is_archived = 0).  
Plan types were defined using CASE, and inactivity days were calculated using DATEDIFF.  
Inactivity days sorted in descending order.   

Tables: plans_plan, savings_savingsaccount  

Key Logic: The criteria is_is_regular_savings = 1 or is_a_fund = 1 were retained in left joins plans with no transactions.
        

Question 4: Customer Lifetime Value (CLV) Estimation  

Objective: Estimate CLV, using the customer tenure, transaction volume and profit of 0.1% per transaction.  

Approach:  
CTE CustomerStats computed tenure (TIMESTAMPDIFF), transaction count, and average profit (confirmed_amount * 0.001) of profit.  

Calculations of CLV was done as (total_transactions / tenure_months) * 12 * avg_profit_per_transaction, subjected to rounding at two decimals.  

Non deleted and active users were filtered and ordered by CLV in descending.  

Tables: users_customuser, savings_savingsaccount.  

Key Logic: Employed LEFT JOIN to include customers with transactions but omitted cases of zero-tenure and zero-transaction.

Obstacles

Discrepancy in Transaction Status: The transaction_status field had several valid options ('success', 'successful', 'monnify_success'). Presumed there was one, but looking at SELECT DISTINCT transaction_status revealed more which were present for all results.

Fund Type Problematic Variable: Problem deciding between is_a_fund and is_fixed_investment for investment plans. Selected is_a_fund derived from data mining but this needed confirmation.

Inactivity Days Misalignment: The example output for Question 3 showed 92 days for a transaction dated 2023-08-10, however the actual date calculated from 2025-05-17 results in approximately ~647 days. It was assumed a dynamic computation was intended.

Worries About Performance: The enormous side of the data (69.8MB SQL dump) posed a threat for excessive duration of queries. Confirmed that there were indexes on crucial fields (information, owner_id, plan_id) and dealt with CTEs for structural readability, but these might be insufficient.

NULL Treatment: Characteristics first_name, last_name, or date_joined potentially having NULL values, may affect query results. In restructured queries, COALESCE was introduced to manage this.

Providing Instructions

Using Docker:

To turn on mysql and phpMyAdmin tools use command run docker-compose up -d in ~/cowrywise.
PhpMyAdmin can be accessed from http://localhost:8080 (user is root with mypassword as password).

Loading The Db:

Use command adashi_assessment.sql:docker exec cowrywise-mysqldb-1 mysql -uroot -pmypassword adashi_staging -e “SOURCE /sql_files/adashi_assessment.sql”

Run The Queries:

Individually insert each Assessment_QX.sql into the SQL box on phpMyAdmin or execute via CLI using command: docker exec cowrywise-mysqldb-1 mysql -uroot -pmypassword adashi_staging < Assessment_QX.sql


