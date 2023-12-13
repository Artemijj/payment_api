create or replace PACKAGE ut_common_pack IS

    /*
    Автор А.А. Лаптев
    Описание скрипта: Вспомогательные модули для организации тест-кейсов

    */

  -- Поля Клиента
    c_client_field_email_id CONSTANT client_data_field.field_id%TYPE := 1;
    c_client_mobile_phone_id CONSTANT client_data_field.field_id%TYPE := 2;
    c_client_inn_id CONSTANT client_data_field.field_id%TYPE := 3;
    c_client_birthday_id CONSTANT client_data_field.field_id%TYPE := 4;
    c_non_existing_payment_id CONSTANT payment.payment_id%TYPE := -777;
    c_payment_detail_app_name_id CONSTANT payment_detail_field.field_id%TYPE := 1;
    c_payment_detail_ip_id CONSTANT payment_detail_field.field_id%TYPE := 2;
    c_payment_detail_created_id CONSTANT payment_detail_field.field_id%TYPE := 3;
    c_payment_detail_unchecked_id CONSTANT payment_detail_field.field_id%TYPE := 4;
    c_payment_detail_value_created CONSTANT payment_detail.field_value%TYPE := 'Created';
    c_payment_detail_value_executed CONSTANT payment_detail.field_value%TYPE := 'Executed';
    c_payment_detail_value_unchecked CONSTANT payment_detail.field_value%TYPE := 'Unchecked';
    c_payment_detail_value_checked CONSTANT payment_detail.field_value%TYPE := 'Checked';

  -- Сообщения об ошибках
    c_error_msg_tech_date_failed CONSTANT VARCHAR2(100 CHAR) := 'Технические даты разные!';
    c_error_msg_test_failed CONSTANT VARCHAR2(100 CHAR) := 'Unit-тест не прошёл';

  -- Коды ошибок
    c_error_code_tech_date_failed CONSTANT NUMBER(10) := -20998;
    c_error_code_test_failed CONSTANT NUMBER(10) := -20999;

  -- Генерация значений полей для сущности клиент
    FUNCTION get_random_client_email RETURN client_data.field_value%TYPE;

    FUNCTION get_random_client_mobile_phone RETURN client_data.field_value%TYPE;

    FUNCTION get_random_client_inn RETURN client_data.field_value%TYPE;

    FUNCTION get_random_client_bday RETURN client_data.field_value%TYPE;

  -- Генерация значений полей для сущности платёж
    FUNCTION get_random_payment_summa RETURN payment.summa%TYPE;

    FUNCTION get_random_payment_currency_id RETURN payment.currency_id%TYPE;

    FUNCTION get_random_payment_detail_app_name RETURN payment_detail.field_value%TYPE;

    FUNCTION get_random_payment_detail_ip RETURN payment_detail.field_value%TYPE;

    FUNCTION get_random_reason RETURN payment.status_change_reason%TYPE;

  -- Создание клиента
    FUNCTION create_default_client (
        p_client_data t_client_data_array := NULL
    ) RETURN client.client_id%TYPE;

  -- Создание платежа
    FUNCTION create_default_payment (
        p_payment_detail t_payment_detail_array := NULL,
        p_current_dtime  payment.create_dtime%TYPE := NULL,
        p_summa          payment.summa%TYPE := NULL,
        p_currency_id    payment.currency_id%TYPE := NULL,
        p_from_client_id payment.from_client_id%TYPE := NULL,
        p_to_client_id   payment.to_client_id%TYPE := NULL
    ) RETURN payment.payment_id%TYPE;

  -- Получить информацию по сущности "Платёж"
    FUNCTION get_payment_info (
        p_payment_id payment_detail.payment_id%TYPE
    ) RETURN payment%rowtype;

  -- Получить данные по полю платежа
    FUNCTION get_payment_field_value (
        p_payment_id payment_detail.payment_id%TYPE,
        p_field_id   payment_detail.field_id%TYPE
    ) RETURN payment_detail.field_value%TYPE;

  -- Возбуждение исключения о неверном тесте
    PROCEDURE ut_failed;

  -- Возбуждение исключения о неверных технических датах
    PROCEDURE ut_tech_date_failed;

  -- Включение ручного режима
    PROCEDURE enable_manual_state;

  -- Выключение ручного режима
    PROCEDURE disable_manual_state;

END ut_common_pack;
/
