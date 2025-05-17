-- Flag accounts with no transactions for over 365 days
WITH LastTransaction AS (
    -- Find the most recent transaction per plan
    SELECT 
        s.plan_id,
        MAX(s.transaction_date) AS last_transaction_date
    FROM savings_savingsaccount s
    WHERE s.transaction_status IN ('success', 'successful', 'monnify_success')
        AND s.confirmed_amount > 0
    GROUP BY s.plan_id
)
SELECT 
    p.id AS plan_id,
    p.owner_id,
    CASE 
        WHEN p.is_regular_savings = 1 THEN 'Savings'
        WHEN p.is_a_fund = 1 THEN 'Investment'  
        ELSE 'Unknown'
    END AS type,
    lt.last_transaction_date,
    COALESCE(DATEDIFF(CURRENT_TIMESTAMP(), lt.last_transaction_date), 9999) AS inactivity_days
FROM plans_plan p
LEFT JOIN LastTransaction lt ON p.id = lt.plan_id
WHERE (p.is_regular_savings = 1 OR p.is_a_fund = 1)
    AND p.is_deleted = 0
    AND p.is_archived = 0
    AND (lt.last_transaction_date IS NULL 
         OR lt.last_transaction_date < DATE_SUB(CURRENT_TIMESTAMP(), INTERVAL 365 DAY))
ORDER BY inactivity_days DESC;
