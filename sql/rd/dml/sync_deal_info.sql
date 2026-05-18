DELETE FROM rd.deal_info di
USING stage.deal_info sdi
WHERE di.deal_rk = sdi.deal_rk::BIGINT
    AND di.deal_num IS NOT DISTINCT FROM sdi.deal_num::TEXT
    AND di.deal_name IS NOT DISTINCT FROM sdi.deal_name::TEXT
    AND di.deal_sum IS NOT DISTINCT FROM sdi.deal_sum::NUMERIC
    AND di.client_rk = sdi.client_rk::BIGINT
    AND di.account_rk = sdi.account_rk::BIGINT
    AND di.agreement_rk = sdi.agreement_rk::BIGINT
    AND di.deal_start_date IS NOT DISTINCT FROM sdi.deal_start_date::DATE
    AND di.department_rk IS NOT DISTINCT FROM sdi.department_rk::BIGINT
    AND di.product_rk IS NOT DISTINCT FROM sdi.product_rk::BIGINT
    AND di.deal_type_cd IS NOT DISTINCT FROM sdi.deal_type_cd::TEXT
    AND di.effective_from_date = sdi.effective_from_date::DATE
    AND di.effective_to_date = sdi.effective_to_date::DATE;

INSERT INTO rd.deal_info (
    deal_rk,
    deal_num,
    deal_name,
    deal_sum,
    client_rk,
    account_rk,
    agreement_rk,
    deal_start_date,
    department_rk,
    product_rk,
    deal_type_cd,
    effective_from_date,
    effective_to_date
)
SELECT DISTINCT
    sdi.deal_rk::BIGINT,
    sdi.deal_num::TEXT,
    sdi.deal_name::TEXT,
    sdi.deal_sum::NUMERIC,
    sdi.client_rk::BIGINT,
    sdi.account_rk::BIGINT,
    sdi.agreement_rk::BIGINT,
    sdi.deal_start_date::DATE,
    sdi.department_rk::BIGINT,
    sdi.product_rk::BIGINT,
    sdi.deal_type_cd::TEXT,
    sdi.effective_from_date::DATE,
    sdi.effective_to_date::DATE
FROM stage.deal_info sdi
WHERE sdi.deal_rk IS NOT NULL
    AND sdi.client_rk IS NOT NULL
    AND sdi.account_rk IS NOT NULL
    AND sdi.agreement_rk IS NOT NULL
    AND sdi.effective_from_date IS NOT NULL
    AND sdi.effective_to_date IS NOT NULL;