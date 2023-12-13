CREATE OR REPLACE TRIGGER payment_b_d_restrict BEFORE
    DELETE ON payment
BEGIN
    payment_api_pack.check_payment_delete_restriction();
END;
/