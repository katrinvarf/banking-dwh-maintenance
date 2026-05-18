DELETE FROM rd.product p
USING stage.product sp
WHERE p.product_rk = sp.product_rk::BIGINT
    AND p.product_name IS NOT DISTINCT FROM sp.product_name::TEXT
    AND p.effective_from_date = sp.effective_from_date::DATE
    AND p.effective_to_date = sp.effective_to_date::DATE;

INSERT INTO rd.product (
    product_rk,
    product_name,
    effective_from_date,
    effective_to_date
)
SELECT DISTINCT
    sp.product_rk::BIGINT,
    sp.product_name::TEXT,
    sp.effective_from_date::DATE,
    sp.effective_to_date::DATE
FROM stage.product sp
WHERE sp.product_rk IS NOT NULL
    AND sp.effective_from_date IS NOT NULL
    AND sp.effective_to_date IS NOT NULL;