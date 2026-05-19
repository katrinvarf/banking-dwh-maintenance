WITH account_balance_with_next_sum AS (
    SELECT 
        account_rk,
        effective_date,
        account_in_sum,
        account_out_sum,
        LEAD(account_in_sum) OVER (PARTITION BY account_rk ORDER BY effective_date) AS next_account_in_sum
    FROM rd.account_balance
)

SELECT 
	account_rk,
	effective_date,
	account_in_sum,
	CASE 
		WHEN next_account_in_sum IS NOT NULL
            AND next_account_in_sum IS DISTINCT FROM account_out_sum 
		THEN next_account_in_sum
		ELSE account_out_sum
	END AS correct_account_out_sum
FROM account_balance_with_next_sum;