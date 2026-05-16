BEGIN;

-- Количество строк до очистки и ожидаемое количество строк после удаления полных дублей
SELECT 
	COUNT(*) AS total_rows_before,
	(
		SELECT COUNT(*)
		FROM (
			SELECT DISTINCT *
			FROM dm.client
		) unique_rows
	) AS expected_rows_after_cleanup
FROM dm.client;

-- Проверка дублей до удаления
SELECT 
	client_rk, 
	effective_from_date, 
	effective_to_date, 
	account_rk, 
	address_rk, 
	department_rk, 
	card_type_code, 
	client_id, 
	counterparty_type_cd, 
	black_list_flag, 
	client_open_dttm, 
	bankruptcy_rk, 
	COUNT(*) AS duplicates_count
FROM dm.client
GROUP BY 
	client_rk, 
	effective_from_date, 
	effective_to_date, 
	account_rk, 
	address_rk, 
	department_rk, 
	card_type_code, 
	client_id, 
	counterparty_type_cd, 
	black_list_flag, 
	client_open_dttm, 
	bankruptcy_rk
HAVING COUNT(*) > 1;

-- Удаление полных дублей
WITH rows_to_delete AS (
	SELECT ctid
	FROM (
		SELECT
			ctid,
			ROW_NUMBER() OVER (
				PARTITION BY 
					client_rk, 
					effective_from_date, 
					effective_to_date, 
					account_rk, 
					address_rk, 
					department_rk, 
					card_type_code, 
					client_id, 
					counterparty_type_cd, 
					black_list_flag, 
					client_open_dttm, 
					bankruptcy_rk
				ORDER BY ctid
			) AS rn
		FROM dm.client
	) numbered_rows
	WHERE numbered_rows.rn > 1
)

DELETE FROM dm.client cl
USING rows_to_delete AS del
WHERE del.ctid = cl.ctid;

-- Проверка количества строк после удаления
SELECT COUNT(*) AS total_rows_after
FROM dm.client;

-- Проверка дублей после удаления
SELECT 
	client_rk, 
	effective_from_date, 
	effective_to_date, 
	account_rk, 
	address_rk, 
	department_rk, 
	card_type_code, 
	client_id, 
	counterparty_type_cd, 
	black_list_flag, 
	client_open_dttm, 
	bankruptcy_rk, 
	COUNT(*) AS duplicates_count
FROM dm.client
GROUP BY
	client_rk, 
	effective_from_date, 
	effective_to_date, 
	account_rk, 
	address_rk, 
	department_rk, 
	card_type_code, 
	client_id, 
	counterparty_type_cd, 
	black_list_flag, 
	client_open_dttm, 
	bankruptcy_rk
HAVING COUNT(*) > 1;

COMMIT;
-- ROLLBACK;