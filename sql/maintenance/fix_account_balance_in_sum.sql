BEGIN;

WITH account_balance_with_prev_sum AS (
    SELECT 
        account_rk,
        effective_date,
        account_in_sum,
        account_out_sum,
        LAG(account_out_sum) OVER (PARTITION BY account_rk ORDER BY effective_date) AS prev_account_out_sum
    FROM rd.account_balance
),

correct_account_balance AS (
    SELECT 
        account_rk,
        effective_date,
        CASE 
            WHEN prev_account_out_sum IS NOT NULL
                AND prev_account_out_sum IS DISTINCT FROM account_in_sum
            THEN prev_account_out_sum
            ELSE account_in_sum
        END AS correct_account_in_sum,
        account_out_sum
    FROM account_balance_with_prev_sum
)

UPDATE rd.account_balance ab
SET account_in_sum = cab.correct_account_in_sum
FROM correct_account_balance cab
WHERE cab.account_rk = ab.account_rk 
    AND cab.effective_date = ab.effective_date
    AND cab.correct_account_in_sum IS DISTINCT FROM ab.account_in_sum;

-- Проверка расхождений после исправления
WITH account_balance_with_prev_sum AS (
    SELECT 
        account_rk,
        effective_date,
        account_in_sum,
        account_out_sum,
        LAG(account_out_sum) OVER (PARTITION BY account_rk ORDER BY effective_date) AS prev_account_out_sum
    FROM rd.account_balance
)
SELECT 
    account_rk,
    effective_date,
    account_in_sum,
    prev_account_out_sum
FROM account_balance_with_prev_sum
WHERE prev_account_out_sum IS NOT NULL
    AND prev_account_out_sum IS DISTINCT FROM account_in_sum;

COMMIT;
-- ROLLBACK;