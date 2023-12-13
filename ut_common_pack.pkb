create or replace PACKAGE BODY ut_common_pack IS

    -- Генерация значения полей для сущности клиент
    FUNCTION get_random_client_email RETURN client_data.field_value%TYPE IS
    BEGIN
        RETURN dbms_random.string(
                                 'l',
                                 10
               )
               || '@'
               || dbms_random.string(
                                    'l',
                                    10
                  )
               || '.com';
    END;

    FUNCTION get_random_client_mobile_phone RETURN client_data.field_value%TYPE IS
    BEGIN
        RETURN '+7'
               || trunc(dbms_random.value(
                                         79000000000,
                                         79999999999
                        ));
    END;

    FUNCTION get_random_client_inn RETURN client_data.field_value%TYPE IS
    BEGIN
        RETURN trunc(dbms_random.value(
                                      1000000000000,
                                      99999999999999
                     ));
    END;

    FUNCTION get_random_client_bday RETURN client_data.field_value%TYPE IS
    BEGIN
        RETURN add_months(
                         trunc(sysdate),
                         -trunc(dbms_random.value(
                                                 18 * 12,
                                                 50 * 12
                                ))
               );
    END;

    FUNCTION get_random_payment_summa RETURN payment.summa%TYPE IS
    BEGIN
        RETURN trunc(dbms_random.value(
                                      1,
                                      99999999999999
                     ));
    END;

    FUNCTION get_random_payment_currency_id RETURN payment.currency_id%TYPE IS
        v_currency_id payment.currency_id%TYPE;
    BEGIN
        SELECT
            currency_id
        INTO v_currency_id
        FROM
            currency
        ORDER BY
            dbms_random.value
        FETCH NEXT 1 ROWS ONLY;

        RETURN v_currency_id;
    END;

    FUNCTION get_random_payment_detail_app_name RETURN payment_detail.field_value%TYPE IS
    BEGIN
        RETURN dbms_random.string(
                                 'u',
                                 10
               )
               || dbms_random.value(
                                   1,
                                   100
                  );
    END;

    FUNCTION get_random_payment_detail_ip RETURN payment_detail.field_value%TYPE IS
    BEGIN
        RETURN dbms_random.value(
                                1,
                                255
               )
               || '.'
               || dbms_random.value(
                                   0,
                                   255
                  )
               || '.'
               || dbms_random.value(
                                   0,
                                   255
                  )
               || '.'
               || dbms_random.value(
                                   0,
                                   255
                  );
    END;

    FUNCTION get_random_reason RETURN payment.status_change_reason%TYPE IS
    BEGIN
        RETURN dbms_random.string(
                                 'a',
                                 100
               );
    END;

    FUNCTION create_default_client (
        p_client_data t_client_data_array := NULL
    ) RETURN client.client_id%TYPE IS
        v_client_data t_client_data_array := p_client_data;
    BEGIN
    -- если ничего не передано, то по умолчанию генерим какие-то значения
        IF v_client_data IS NULL OR v_client_data IS EMPTY THEN
            v_client_data := t_client_data_array(
                                                t_client_data(
                                                             c_client_field_email_id,
                                                             get_random_client_email()
                                                ),
                                                t_client_data(
                                                             c_client_mobile_phone_id,
                                                             get_random_client_mobile_phone()
                                                ),
                                                t_client_data(
                                                             c_client_inn_id,
                                                             get_random_client_inn()
                                                ),
                                                t_client_data(
                                                             c_client_birthday_id,
                                                             get_random_client_bday()
                                                )
                             );
        END IF;

        RETURN client_api_pack.create_client(p_client_data => v_client_data);
    END;

    FUNCTION create_default_payment (
        p_payment_detail t_payment_detail_array := NULL,
        p_current_dtime  payment.create_dtime%TYPE := NULL,
        p_summa          payment.summa%TYPE := NULL,
        p_currency_id    payment.currency_id%TYPE := NULL,
        p_from_client_id payment.from_client_id%TYPE := NULL,
        p_to_client_id   payment.to_client_id%TYPE := NULL
    ) RETURN payment.payment_id%TYPE IS

        v_payment_detail t_payment_detail_array := p_payment_detail;
        v_current_dtime  payment.create_dtime%TYPE;
        v_summa          payment.summa%TYPE;
        v_currency_id    payment.currency_id%TYPE;
        v_from_client_id payment.from_client_id%TYPE;
        v_to_client_id   payment.to_client_id%TYPE;
    BEGIN
        IF v_payment_detail IS NULL OR v_payment_detail IS EMPTY THEN
            v_payment_detail := t_payment_detail_array(
                                                      t_payment_detail(
                                                                      c_payment_detail_app_name_id,
                                                                      get_random_payment_detail_app_name()
                                                      ),
                                                      t_payment_detail(
                                                                      c_payment_detail_ip_id,
                                                                      get_random_payment_detail_ip()
                                                      ),
                                                      t_payment_detail(
                                                                      c_payment_detail_created_id,
                                                                      c_payment_detail_value_created
                                                      ),
                                                      t_payment_detail(
                                                                      c_payment_detail_unchecked_id,
                                                                      c_payment_detail_value_unchecked
                                                      )
                                );
        END IF;

        IF p_current_dtime IS NULL THEN
            v_current_dtime := systimestamp;
        END IF;
        IF p_summa IS NULL THEN
            v_summa := get_random_payment_summa();
        END IF;
        IF p_currency_id IS NULL THEN
            v_currency_id := get_random_payment_currency_id();
        END IF;
        IF v_from_client_id IS NULL THEN
            v_from_client_id := create_default_client();
        END IF;
        IF v_to_client_id IS NULL THEN
            v_to_client_id := create_default_client();
        END IF;
        RETURN payment_api_pack.create_payment(
                                              p_payment_detail => v_payment_detail,
                                              p_current_dtime  => v_current_dtime,
                                              p_summa          => v_summa,
                                              p_currency_id    => v_currency_id,
                                              p_from_client_id => v_from_client_id,
                                              p_to_client_id   => v_to_client_id
               );

    END;

    FUNCTION get_payment_info (
        p_payment_id payment_detail.payment_id%TYPE
    ) RETURN payment%rowtype IS
        v_payment payment%rowtype;
    BEGIN
        SELECT
            *
        INTO v_payment
        FROM
            payment pay
        WHERE
            pay.payment_id = p_payment_id;

        RETURN v_payment;
    END;

    FUNCTION get_payment_field_value (
        p_payment_id payment_detail.payment_id%TYPE,
        p_field_id   payment_detail.field_id%TYPE
    ) RETURN payment_detail.field_value%TYPE IS
        v_field_value payment_detail.field_value%TYPE;
    BEGIN
        SELECT
            MAX(pd.field_value)
        INTO v_field_value
        FROM
            payment_detail pd
        WHERE
            pd.payment_id = p_payment_id
            AND pd.field_id = p_field_id;

        RETURN v_field_value;
    END;

    PROCEDURE ut_tech_date_failed IS
    BEGIN
        raise_application_error(
                               c_error_code_test_failed,
                               c_error_msg_test_failed
        );
    END;

    PROCEDURE ut_failed IS
    BEGIN
        raise_application_error(
                               c_error_code_test_failed,
                               c_error_msg_test_failed
        );
    END;

    PROCEDURE enable_manual_state IS
    BEGIN
        common_pack.enable_manual_changes();
    END;

    PROCEDURE disable_manual_state IS
    BEGIN
        common_pack.disable_manual_changes();
    EXCEPTION
        WHEN OTHERS THEN
            common_pack.disable_manual_changes();
            RAISE;
    END;

END ut_common_pack;
/
