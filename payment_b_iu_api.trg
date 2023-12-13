CREATE OR REPLACE TRIGGER payment_b_iu_api BEFORE
    INSERT OR UPDATE ON payment
BEGIN
    -- Проверка выполнения команд через API
    payment_api_pack.is_changes_through_api();
END;
/