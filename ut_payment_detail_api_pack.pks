create or replace package ut_payment_detail_api_pack is

    /*
    Автор А.А. Лаптев
    Описание скрипта: Тесты для работы с данными платежа

    */

  --%suite(Test payment_detail_api_pack)

  --%test(Данные платежа добавлены или обновлены)
    procedure insert_or_update_payment_detail;

  --%test(Проверка "Детали платежа удалены)
    procedure delete_payment_detail;

  --%test(Проверка функционала по глобальному отключению проверок. Операция изменения деталей платежа)
  --%beforetest(ut_common_pack.enable_manual_state)
  --%aftertest(ut_common_pack.disable_manual_state)
    procedure update_payment_detail_with_direct_dml_and_enabled_manual_change;

  -- Негативные Unit-тесты

  --%test(Проверка "Детали платежа удалены v_delete_field_ids = null")
  --%throws(common_pack.c_error_code_invalid_input_parameter)
    procedure delete_payment_detail_with_empty_array_should_fail;

  --%test(Проверка запрета вставки в payment_detail не через API)
  --%throws(common_pack.c_error_code_manual_changes)
    procedure direct_insert_payment_detail_should_fail;

  --%test(Данные платежа добавлены или обновлены с пустым массивом payment_detail)
  --%throws(common_pack.c_error_code_invalid_input_parameter)
    procedure insert_or_update_payment_detail_with_empty_payment_detail_array;

  --%test(Проверка "Детали платежа удалены payment_id = null")
  --%throws(common_pack.c_error_code_invalid_input_parameter)
    procedure delete_payment_detail_with_null_payment_id_should_fail;

  --%test(Проверка запрета обновления payment_detail не через API)
  --%throws(common_pack.c_error_code_manual_changes)
    procedure direct_update_payment_detail_should_fail;

  --%test(Проверка запрета удаления в payment_detail не через API)
  --%throws(common_pack.c_error_code_manual_changes)
    procedure direct_delete_payment_detail_should_fail;

end ut_payment_detail_api_pack;
/
