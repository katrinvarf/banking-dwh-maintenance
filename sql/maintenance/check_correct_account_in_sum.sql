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
	CASE 
		WHEN prev_account_out_sum IS NOT NULL
            AND prev_account_out_sum IS DISTINCT FROM account_in_sum
		THEN prev_account_out_sum
		ELSE account_in_sum
	END AS correct_account_in_sum,
	account_out_sum
FROM account_balance_with_prev_sum;