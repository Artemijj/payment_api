create or replace PACKAGE BODY payment_api_pack IS

    g_is_api BOOLEAN := FALSE;

    PROCEDURE allow_changes IS
    BEGIN
        g_is_api := TRUE;
    END;

    PROCEDURE disallow_changes IS
    BEGIN
        g_is_api := FALSE;
    END;

-- Платеж создан
    FUNCTION create_payment (
        p_payment_detail t_payment_detail_array,
        p_current_dtime payment.create_dtime%TYPE,
        p_summa          payment.summa%TYPE,
        p_currency_id    payment.currency_id%TYPE,
        p_from_client_id payment.from_client_id%TYPE,
        p_to_client_id   payment.to_client_id%TYPE
    ) RETURN payment.payment_id%TYPE IS
        v_payment_id    payment.payment_id%TYPE;
    BEGIN
        allow_changes();
        INSERT INTO payment (
            payment_id,
            create_dtime,
            summa,
            currency_id,
            from_client_id,
            to_client_id
        ) VALUES (
            payment_seq.NEXTVAL,
            p_current_dtime,
            p_summa,
            p_currency_id,
            p_from_client_id,
            p_to_client_id
        ) RETURNING payment_id INTO v_payment_id;

        payment_detail_api_pack.insert_or_update_payment_detail(
                                                               p_payment_id     => v_payment_id,
                                                               p_payment_detail => p_payment_detail
        );
        disallow_changes();
        RETURN v_payment_id;
    EXCEPTION
        WHEN OTHERS THEN
            disallow_changes();
            RAISE;
    END;

-- Сброс платежа
    PROCEDURE fail_payment (
        p_payment_id payment.payment_id%TYPE,
        p_reason     payment.status_change_reason%TYPE
    ) IS
    BEGIN
        IF p_payment_id IS NULL THEN
            raise_application_error(
                                   common_pack.c_error_code_invalid_input_parameter,
                                   common_pack.c_error_msg_empty_object_id
            );
        END IF;

        IF p_reason IS NULL THEN
            raise_application_error(
                                   common_pack.c_error_code_invalid_input_parameter,
                                   common_pack.c_error_msg_empty_reason
            );
        END IF;

        try_lock_payment(p_payment_id => p_payment_id);
        allow_changes();
        UPDATE payment p
        SET
            p.status = c_status_fail,
            p.status_change_reason = p_reason
        WHERE
            p.payment_id = p_payment_id
            AND p.status = c_status_create;

        disallow_changes();
    EXCEPTION
        WHEN OTHERS THEN
            disallow_changes();
            RAISE;
    END;

-- Отмена платежа
    PROCEDURE cancel_payment (
        p_payment_id payment.payment_id%TYPE,
        p_reason     payment.status_change_reason%TYPE
    ) IS
    BEGIN
        IF p_payment_id IS NULL THEN
            raise_application_error(
                                   common_pack.c_error_code_invalid_input_parameter,
                                   common_pack.c_error_msg_empty_object_id
            );
        END IF;

        IF p_reason IS NULL THEN
            raise_application_error(
                                   common_pack.c_error_code_invalid_input_parameter,
                                   common_pack.c_error_msg_empty_reason
            );
        END IF;

        try_lock_payment(p_payment_id => p_payment_id);
        allow_changes();
        UPDATE payment p
        SET
            p.status = c_status_cancel,
            p.status_change_reason = p_reason
        WHERE
            p.payment_id = p_payment_id
            AND p.status = c_status_create;

        disallow_changes();
    EXCEPTION
        WHEN OTHERS THEN
            disallow_changes();
            RAISE;
    END;

-- Успешное завершение платежа
    PROCEDURE successful_finish_payment (
        p_payment_id payment.payment_id%TYPE
    ) IS
    BEGIN
        IF p_payment_id IS NULL THEN
            raise_application_error(
                                   common_pack.c_error_code_invalid_input_parameter,
                                   common_pack.c_error_msg_empty_object_id
            );
        END IF;

        try_lock_payment(p_payment_id => p_payment_id);
        allow_changes();
        UPDATE payment p
        SET
            p.status = c_status_successful
        WHERE
            p.payment_id = p_payment_id
            AND p.status = c_status_create;

        disallow_changes();
    EXCEPTION
        WHEN OTHERS THEN
            disallow_changes();
            RAISE;
    END;

-- Проверка, допустимости изменения клиента
    PROCEDURE is_changes_through_api IS
    BEGIN
        IF
            NOT g_is_api
            AND NOT common_pack.is_manual_changes_allowed()
        THEN
            raise_application_error(
                                   common_pack.c_error_code_manual_changes,
                                   common_pack.c_error_msg_manual_changes
            );
        END IF;
    END;

-- Проверка, на возможность удалять данные
    PROCEDURE check_payment_delete_restriction IS
    BEGIN
        IF NOT common_pack.is_manual_changes_allowed() THEN
            raise_application_error(
                                   common_pack.c_error_code_delete_forbidden,
                                   common_pack.c_error_msg_delete_forbidden
            );
        END IF;
    END;

    -- Блокировка платежа для изменений
    PROCEDURE try_lock_payment (
        p_payment_id payment.payment_id%TYPE
    ) IS
        v_status payment.status%TYPE;
    BEGIN
    -- блокируем платёж
        SELECT
            status
        INTO v_status
        FROM
            payment t
        WHERE
            t.payment_id = p_payment_id
        FOR UPDATE NOWAIT;

    -- объект уже неактивен
        IF v_status != c_status_create THEN
            raise_application_error(
                                   common_pack.c_error_code_final_state_object,
                                   common_pack.c_error_msg_final_state_object
            );
        END IF;

    EXCEPTION
    -- такой клиент не найден
        WHEN no_data_found THEN
            raise_application_error(
                                   common_pack.c_error_code_object_notfound,
                                   common_pack.c_error_msg_object_notfound
            );
    -- объект не удалось заблокировать
        WHEN common_pack.e_row_locked THEN
            raise_application_error(
                                   common_pack.c_error_code_object_already_locked,
                                   common_pack.c_error_msg_object_already_locked
            );
    END;

END;
/