create or replace package body ut_payment_detail_api_pack is

-- Проверка "Данные платежа добавлены или обновлены"
    procedure insert_or_update_payment_detail is

        v_payment_id          payment.payment_id%type;
        v_app_name            payment_detail.field_value%type := ut_common_pack.get_random_payment_detail_app_name();
        v_ip                  payment_detail.field_value%type := ut_common_pack.get_random_payment_detail_ip();
        v_payment_detail      t_payment_detail_array := t_payment_detail_array(
                                                                         t_payment_detail(
                                                                                         ut_common_pack.c_payment_detail_app_name_id,
                                                                                         v_app_name
                                                                         ),
                                                                         t_payment_detail(
                                                                                         ut_common_pack.c_payment_detail_ip_id,
                                                                                         v_ip
                                                                         )
                                                   );
        v_app_name_after_test payment_detail.field_value%type;
        v_ip_after_test       payment_detail.field_value%type;
    begin
        v_payment_id := ut_common_pack.create_default_payment();
        payment_detail_api_pack.insert_or_update_payment_detail(
                                                               p_payment_id     => v_payment_id,
                                                               p_payment_detail => v_payment_detail
        );
        v_app_name_after_test := ut_common_pack.get_payment_field_value(
                                                                       v_payment_id,
                                                                       ut_common_pack.c_payment_detail_app_name_id
                                 );
        v_ip_after_test := ut_common_pack.get_payment_field_value(
                                                                 v_payment_id,
                                                                 ut_common_pack.c_payment_detail_ip_id
                           );
        ut.expect(v_app_name, ut_common_pack.c_error_msg_test_failed).to_equal(v_app_name_after_test);
        ut.expect(v_ip, ut_common_pack.c_error_msg_test_failed).to_equal(v_ip_after_test);

    end;

-- Проверка "Детали платежа удалены"
    procedure delete_payment_detail is

        v_payment_id          payment.payment_id%type;
        v_delete_field_ids    t_number_array := t_number_array(
                                                           ut_common_pack.c_payment_detail_app_name_id,
                                                           ut_common_pack.c_payment_detail_ip_id
                                             );
        v_app_name_after_test payment_detail.field_value%type;
        v_ip_after_test       payment_detail.field_value%type;
    begin
        v_payment_id := ut_common_pack.create_default_payment();
        payment_detail_api_pack.delete_payment_detail(
                                                     p_payment_id       => v_payment_id,
                                                     p_delete_field_ids => v_delete_field_ids
        );
        v_app_name_after_test := ut_common_pack.get_payment_field_value(
                                                                       v_payment_id,
                                                                       ut_common_pack.c_payment_detail_app_name_id
                                 );
        v_ip_after_test := ut_common_pack.get_payment_field_value(
                                                                 v_payment_id,
                                                                 ut_common_pack.c_payment_detail_ip_id
                           );
        ut.expect(v_app_name_after_test, ut_common_pack.c_error_msg_test_failed).to_be_null();
        ut.expect(v_ip_after_test, ut_common_pack.c_error_msg_test_failed).to_be_null();

    end;

-- Проверка функционала по глобальному отключению проверок. Операция изменения деталей платежа
    procedure update_payment_detail_with_direct_dml_and_enabled_manual_change is

        v_payment_id payment.payment_id%type := ut_common_pack.c_non_existing_payment_id;
        v_field_id   payment_detail.field_id%type := ut_common_pack.c_payment_detail_app_name_id;
    begin
        update payment_detail pd
        set
            pd.field_value = pd.field_value
        where
            pd.payment_id = v_payment_id
            and pd.field_id = v_field_id;

    end;

-- Негативные Unit-тесты

-- Проверка "Детали платежа удалены v_delete_field_ids = null"
    procedure delete_payment_detail_with_empty_array_should_fail is
        v_payment_id       payment.payment_id%type;
        v_delete_field_ids t_number_array := null;
    begin
        v_payment_id := ut_common_pack.create_default_payment();
        payment_detail_api_pack.delete_payment_detail(
                                                     p_payment_id       => v_payment_id,
                                                     p_delete_field_ids => v_delete_field_ids
        );
    end;

-- Проверка запрета вставки в payment_detail не через API
    procedure direct_insert_payment_detail_should_fail is
        v_payment_id payment.payment_id%type;
        v_field_id   payment_detail.field_id%type := ut_common_pack.c_payment_detail_app_name_id;
    begin
        v_payment_id := ut_common_pack.create_default_payment();
        insert into payment_detail (
            payment_id,
            field_id
        ) values (
            v_payment_id,
            v_field_id
        );

    end;

-- Проверка "Данные платежа добавлены или обновлены"
    procedure insert_or_update_payment_detail_with_empty_payment_detail_array is
        v_payment_id     payment.payment_id%type;
        v_payment_detail t_payment_detail_array;
    begin
        v_payment_id := ut_common_pack.create_default_payment();
        payment_detail_api_pack.insert_or_update_payment_detail(
                                                               p_payment_id     => v_payment_id,
                                                               p_payment_detail => v_payment_detail
        );
    end;

-- Проверка "Детали платежа удалены"
    procedure delete_payment_detail_with_null_payment_id_should_fail is

        v_payment_id       payment.payment_id%type;
        v_delete_field_ids t_number_array := t_number_array(
                                                           ut_common_pack.c_payment_detail_app_name_id,
                                                           ut_common_pack.c_payment_detail_ip_id
                                             );
    begin
        payment_detail_api_pack.delete_payment_detail(
                                                     p_payment_id       => v_payment_id,
                                                     p_delete_field_ids => v_delete_field_ids
        );
    end;

-- Проверка запрета обновления в payment_detail не через API
    procedure direct_update_payment_detail_should_fail is

        v_payment_id payment.payment_id%type := ut_common_pack.c_non_existing_payment_id;
        v_field_id   payment_detail.field_id%type := ut_common_pack.c_payment_detail_app_name_id;
    begin
        update payment_detail pd
        set
            pd.field_id = v_field_id
        where
            pd.payment_id = v_payment_id;

    end;

-- Проверка запрета удаления в payment_detail не через API
    procedure direct_delete_payment_detail_should_fail is
        v_payment_id payment.payment_id%type := ut_common_pack.c_non_existing_payment_id;
    begin
        delete payment_detail pd
        where
            pd.payment_id = v_payment_id;

    end;

end ut_payment_detail_api_pack;
/