create or replace package ut_payment_api_pack is

    /*
    Автор А.А. Лаптев
    Описание скрипта: Тесты для работы с платежом

    */

  --%suite(Test payment_api_pack)

  --%test(Создание платежа)
    procedure create_payment;

  --%test(Сброс платежа)
    procedure reset_payment;

  --%test(Отмена платежа)
    procedure cancel_payment;

  --%test(Успешное завершение платежа)
    procedure successful_payment;

  --%test(Прямое удаление платежа с отключенными глобальными проверками)
  --%beforetest(ut_common_pack.enable_manual_state)
  --%aftertest(ut_common_pack.disable_manual_state)
    procedure delete_payment_with_direct_dml_and_enabled_manual_change;

  --%test(Прямое изменение платежа с отключенными глобальными проверками)
  --%beforetest(ut_common_pack.enable_manual_state)
  --%aftertest(ut_common_pack.disable_manual_state)
    procedure update_payment_with_direct_dml_and_enabled_manual_change;

  -- Негативные Unit-тесты

  --%test(Отмена платежа с пустой причиной)
  --%throws(common_pack.c_error_code_invalid_input_parameter)
    procedure cancel_payment_with_empty_reason_should_fail;

  --%test(Удаление платежа через delete)
  --%throws(common_pack.c_error_code_delete_forbidden)
    procedure direct_payment_delete_should_fail;

  --%test(Создание платежа с пустым payment_detail)
  --%throws(common_pack.c_error_code_invalid_input_parameter)
    procedure create_payment_with_null_payment_detail;

  --%test(Сброс платежа с пустым payment_id)
  --%throws(common_pack.c_error_code_invalid_input_parameter)
    procedure reset_payment_with_null_payment_id;

  --%test(Успешное завершение платежа с пустым payment_id)
  --%throws(common_pack.c_error_code_invalid_input_parameter)
    procedure successful_finish_payment_with_null_payment_id;

  --%test(Вставка в платёж через insert)
  --%throws(common_pack.c_error_code_manual_changes)
    procedure direct_payment_insert_should_fail;

  --%test(Обновление платежа через update)
  --%throws(common_pack.c_error_code_manual_changes)
    procedure direct_payment_update_should_fail;

  --%test(Отмена несуществующего платежа)
  --%throws(common_pack.c_error_code_object_notfound)
    procedure cancel_non_existing_payment;

  --%test(Попытка изменения статуса платежа, уже находящегося в финальном статусе)
  --%throws(common_pack.c_error_code_final_state_object)
    procedure change_payment_status_in_already_final_status;

end ut_payment_api_pack;
/