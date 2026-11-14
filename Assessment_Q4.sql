-- Estimate CLV based on transaction volume and tenure
WITH CustomerStats AS (
    -- Calculate tenure, transactions, and profit per customer
    SELECT 
        u.id AS customer_id,
        CONCAT(COALESCE(u.first_name, ''), ' ', COALESCE(u.last_name, '')) AS fullname,
        TIMESTAMPDIFF(MONTH, u.date_joined, CURRENT_TIMESTAMP()) + 1 AS tenure_months,
        COUNT(s.id) AS total_transactions,
        AVG(s.confirmed_amount * 0.001) AS avg_profit_per_transaction
    FROM users_customuser u
    LEFT JOIN savings_savingsaccount s ON u.id = s.owner_id
        AND s.transaction_status IN ('success', 'successful', 'monnify_success')
        AND s.confirmed_amount > 0
    WHERE u.is_active = 1
        AND u.is_account_deleted = 0
    GROUP BY u.id, u.first_name, u.last_name, u.date_joined
    HAVING tenure_months > 0 AND total_transactions > 0
)
SELECT 
    customer_id,
    fullname,
    tenure_months,
    total_transactions,
    ROUND((total_transactions / tenure_months) * 12 * avg_profit_per_transaction, 2) AS estimated_clv
FROM CustomerStats
-- Order by highest CLV
ORDER BY estimated_clv DESC;
