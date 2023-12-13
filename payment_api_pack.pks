create or replace PACKAGE payment_api_pack IS

    /*
    Автор А.А. Лаптев
    Описание скрипта: API для сущности “Платеж”

    */

    -- Статусы состояния платежа
    c_status_create CONSTANT payment.status%TYPE := 0;
    c_status_fail CONSTANT payment.status%TYPE := 2;
    c_status_cancel CONSTANT payment.status%TYPE := 3;
    c_status_successful CONSTANT payment.status%TYPE := 1;

    -- API

    -- Платеж создан
    FUNCTION create_payment (
        p_payment_detail t_payment_detail_array,
        p_current_dtime payment.create_dtime%TYPE,
        p_summa          payment.summa%TYPE,
        p_currency_id    payment.currency_id%TYPE,
        p_from_client_id payment.from_client_id%TYPE,
        p_to_client_id   payment.to_client_id%TYPE
    ) RETURN payment.payment_id%TYPE;

    -- Сброс платежа
    PROCEDURE fail_payment (
        p_payment_id payment.payment_id%TYPE,
        p_reason     payment.status_change_reason%TYPE
    );

    -- Отмена платежа
    PROCEDURE cancel_payment (
        p_payment_id payment.payment_id%TYPE,
        p_reason     payment.status_change_reason%TYPE
    );

  -- Успешное завершение платежа
    PROCEDURE successful_finish_payment (
        p_payment_id payment.payment_id%TYPE
    );

    -- Блокировка платежа для изменений
    PROCEDURE try_lock_payment (
        p_payment_id payment.payment_id%TYPE
    );

    -- Triggers

    -- Проверка, допустимости изменения клиента
    PROCEDURE is_changes_through_api;

    -- Проверка, на возможность удалять данные
    PROCEDURE check_payment_delete_restriction;

END;
/