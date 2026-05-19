DELETE FROM dm.dict_currency dc
USING stage.dict_currency sdc
WHERE dc.currency_cd = sdc.currency_cd::TEXT
    AND dc.currency_name = sdc.currency_name::TEXT
    AND dc.effective_from_date = sdc.effective_from_date::DATE
    AND dc.effective_to_date = sdc.effective_to_date::DATE;

INSERT INTO dm.dict_currency (
    currency_cd,
    currency_name,
    effective_from_date,
    effective_to_date
)
SELECT DISTINCT
    sdc.currency_cd::TEXT,
    sdc.currency_name::TEXT,
    sdc.effective_from_date::DATE,
    sdc.effective_to_date::DATE
FROM stage.dict_currency sdc
WHERE sdc.currency_cd IS NOT NULL
    AND sdc.currency_name IS NOT NULL
    AND sdc.effective_from_date IS NOT NULL
    AND sdc.effective_to_date IS NOT NULL;