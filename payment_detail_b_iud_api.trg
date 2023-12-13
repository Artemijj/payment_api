CREATE OR REPLACE TRIGGER payment_detail_b_iud_api BEFORE
    INSERT OR UPDATE OR DELETE ON payment_detail
BEGIN
    -- проверяем выполняется ли изменение через API
    payment_detail_api_pack.is_changes_through_api(); 
END;
/