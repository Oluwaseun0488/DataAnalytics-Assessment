-- Identify customers with both funded savings and investment plans
WITH SavingsPlans AS (
    -- Count savings plans and sum deposits per owner
    SELECT 
        p.owner_id,
        COUNT(DISTINCT p.id) AS savings_count,
        SUM(s.confirmed_amount) AS savings_deposits
    FROM plans_plan p
    JOIN savings_savingsaccount s ON p.id = s.plan_id
    WHERE p.is_regular_savings = 1
        AND s.transaction_status IN ('success', 'successful', 'monnify_success')
        AND s.confirmed_amount > 0
    GROUP BY p.owner_id
),
InvestmentPlans AS (
    -- Count investment plans and sum deposits per owner
    SELECT 
        p.owner_id,
        COUNT(DISTINCT p.id) AS investment_count,
        SUM(s.confirmed_amount) AS investment_deposits
    FROM plans_plan p
    JOIN savings_savingsaccount s ON p.id = s.plan_id
    WHERE p.is_a_fund = 1
        AND s.transaction_status IN ('success', 'successful', 'monnify_success')
        AND s.confirmed_amount > 0
    GROUP BY p.owner_id
)
SELECT 
    u.id AS owner_id,
    CONCAT(COALESCE(u.first_name, ''), ' ', COALESCE(u.last_name, '')) AS fullname,
    s.savings_count,
    i.investment_count,
    ROUND((COALESCE(s.savings_deposits, 0) + COALESCE(i.investment_deposits, 0)) / 100, 2) AS total_deposits_naira
FROM users_customuser u
JOIN SavingsPlans s ON u.id = s.owner_id
JOIN InvestmentPlans i ON u.id = i.owner_id
WHERE u.is_active = 1 AND u.is_account_deleted = 0
ORDER BY total_deposits_naira DESC;
