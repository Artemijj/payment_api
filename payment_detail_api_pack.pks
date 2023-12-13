create or replace PACKAGE payment_detail_api_pack IS

/*
Автор А.А. Лаптев
Описание скрипта: API для сущности “Детали платежа”

*/

    -- Данные платежа добавлены или обновлены
    PROCEDURE insert_or_update_payment_detail (
        p_payment_id     payment.payment_id%TYPE,
        p_payment_detail t_payment_detail_array
    );

    -- Детали платежа удалены
    PROCEDURE delete_payment_detail (
        p_payment_id       payment.payment_id%TYPE,
        p_delete_field_ids t_number_array
    );

    -- Проверка, вызываемая из триггера
    PROCEDURE is_changes_through_api;

END payment_detail_api_pack;
/