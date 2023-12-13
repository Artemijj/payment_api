CREATE OR REPLACE TRIGGER payment_b_iu_tech_fields BEFORE
    INSERT OR UPDATE ON payment
    FOR EACH ROW
DECLARE
    v_current_timestamp payment.create_dtime_tech%TYPE := systimestamp;
BEGIN
    IF inserting THEN
        :new.create_dtime_tech := v_current_timestamp;
    END IF;
    :new.update_dtime_tech := v_current_timestamp;
END;
/