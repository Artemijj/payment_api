create or replace PACKAGE BODY payment_detail_api_pack IS

    g_is_api BOOLEAN := FALSE;

    PROCEDURE allow_changes IS
    BEGIN
        g_is_api := TRUE;
    END;

    PROCEDURE disallow_changes IS
    BEGIN
        g_is_api := FALSE;
    END;

    -- Данные платежа добавлены или обновлены
    PROCEDURE insert_or_update_payment_detail (
        p_payment_id     payment.payment_id%TYPE,
        p_payment_detail t_payment_detail_array
    ) IS
    BEGIN
        IF p_payment_id IS NULL THEN
            raise_application_error(
                                   common_pack.c_error_code_invalid_input_parameter,
                                   common_pack.c_error_msg_empty_object_id
            );
        END IF;

        IF p_payment_detail IS NOT EMPTY THEN
            FOR i IN p_payment_detail.first..p_payment_detail.last LOOP
                IF ( p_payment_detail(i).field_id IS NULL ) THEN
                    raise_application_error(
                                           common_pack.c_error_code_invalid_input_parameter,
                                           common_pack.c_error_msg_empty_field_id
                    );
                END IF;

                IF ( p_payment_detail(i).field_value IS NULL ) THEN
                    raise_application_error(
                                           common_pack.c_error_code_invalid_input_parameter,
                                           common_pack.c_error_msg_empty_field_value
                    );
                END IF;

            END LOOP;

        ELSE
            raise_application_error(
                                   common_pack.c_error_code_invalid_input_parameter,
                                   common_pack.c_error_msg_empty_collection
            );
        END IF;

        payment_api_pack.try_lock_payment(p_payment_id => p_payment_id);
        allow_changes();
        MERGE INTO payment_detail o
        USING (
            SELECT
                p_payment_id         payment_id,
                value(t).field_id    field_id,
                value(t).field_value field_value
            FROM
                TABLE ( p_payment_detail ) t
        ) n ON ( o.payment_id = n.payment_id
                 AND o.field_id = n.field_id )
        WHEN MATCHED THEN UPDATE
        SET o.field_value = n.field_value
        WHEN NOT MATCHED THEN
        INSERT (
            payment_id,
            field_id,
            field_value )
        VALUES
            ( n.payment_id,
              n.field_id,
              n.field_value );

        disallow_changes();
    EXCEPTION
        WHEN OTHERS THEN
            disallow_changes();
            RAISE;
    END;

    -- Детали платежа удалены
    PROCEDURE delete_payment_detail (
        p_payment_id       payment.payment_id%TYPE,
        p_delete_field_ids t_number_array
    ) IS
    BEGIN
        IF p_payment_id IS NULL THEN
            raise_application_error(
                                   common_pack.c_error_code_invalid_input_parameter,
                                   common_pack.c_error_msg_empty_object_id
            );
        END IF;

        IF p_delete_field_ids IS EMPTY OR p_delete_field_ids IS NULL THEN
            raise_application_error(
                                   common_pack.c_error_code_invalid_input_parameter,
                                   common_pack.c_error_msg_empty_collection
            );
        END IF;

        payment_api_pack.try_lock_payment(p_payment_id => p_payment_id);
        allow_changes();
        DELETE payment_detail pd
        WHERE
            pd.payment_id = p_payment_id
            AND pd.field_id IN (
                SELECT
                    value(t)
                FROM
                    TABLE ( p_delete_field_ids ) t
            );

        disallow_changes();
    EXCEPTION
        WHEN OTHERS THEN
            disallow_changes();
            RAISE;
    END;

-- Проверка, вызываемая из триггера
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

END payment_detail_api_pack;
/