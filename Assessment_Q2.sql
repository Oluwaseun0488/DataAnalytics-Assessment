-- Analyze transaction frequency to segment customers
WITH TransactionStats AS (
    -- Calculate transactions and active months per customer
    SELECT 
        s.owner_id,
        COUNT(*) AS total_transactions,
        TIMESTAMPDIFF(MONTH, MIN(s.transaction_date), MAX(s.transaction_date)) + 1 AS months_active,
        COUNT(*) / (TIMESTAMPDIFF(MONTH, MIN(s.transaction_date), MAX(s.transaction_date)) + 1) AS avg_transactions_per_month
    FROM savings_savingsaccount s
    WHERE s.transaction_status IN ('success', 'successful', 'monnify_success')
        AND s.confirmed_amount > 0
    GROUP BY s.owner_id
    HAVING months_active > 0
),
FrequencyCategories AS (
    -- Categorize customers by transaction frequency
    SELECT 
        owner_id,
        CASE 
            WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
            WHEN avg_transactions_per_month >= 3 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category,
        avg_transactions_per_month
    FROM TransactionStats
)
SELECT 
    frequency_category,
    COUNT(DISTINCT owner_id) AS customer_count,
    ROUND(AVG(avg_transactions_per_month), 1) AS avg_transactions_per_month
FROM FrequencyCategories
GROUP BY frequency_category
-- Order categories explicitly
ORDER BY FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');
