create or replace package body ut_payment_api_pack is


-- Проверка "Платеж создан"
    procedure create_payment is

        v_payment_detail t_payment_detail_array := t_payment_detail_array(
                                                                         t_payment_detail(
                                                                                         ut_common_pack.c_payment_detail_app_name_id,
                                                                                         ut_common_pack.get_random_payment_detail_app_name
                                                                                         ()
                                                                         ),
                                                                         t_payment_detail(
                                                                                         ut_common_pack.c_payment_detail_ip_id,
                                                                                         ut_common_pack.get_random_payment_detail_ip(
                                                                                         )
                                                                         ),
                                                                         t_payment_detail(
                                                                                         ut_common_pack.c_payment_detail_created_id,
                                                                                         ut_common_pack.c_payment_detail_value_created
                                                                         ),
                                                                         t_payment_detail(
                                                                                         ut_common_pack.c_payment_detail_unchecked_id
                                                                                         ,
                                                                                         ut_common_pack.c_payment_detail_value_unchecked
                                                                         )
                                                   );
        v_payment_id     payment.payment_id%type;
        v_current_dtime  payment.create_dtime%TYPE := systimestamp;
        v_from_client_id payment.from_client_id%type := ut_common_pack.create_default_client();
        v_to_client_id   payment.to_client_id%type := ut_common_pack.create_default_client();
        v_summa          payment.summa%type := ut_common_pack.get_random_payment_summa();
        v_currency_id    payment.currency_id%type := ut_common_pack.get_random_payment_currency_id();
        v_payment        payment%rowtype;
    begin
        v_payment_id := payment_api_pack.create_payment(
                                                       p_payment_detail => v_payment_detail,
                                                       p_current_dtime  => v_current_dtime,
                                                       p_summa          => v_summa,
                                                       p_currency_id    => v_currency_id,
                                                       p_from_client_id => v_from_client_id,
                                                       p_to_client_id   => v_to_client_id
                        );

        v_payment := ut_common_pack.get_payment_info(v_payment_id);

        ut.expect(v_payment.payment_id, ut_common_pack.c_error_msg_test_failed).to_equal(v_payment_id); -- Или это избыточно?
        ut.expect(v_payment.create_dtime, ut_common_pack.c_error_msg_test_failed).to_equal(v_current_dtime);
        ut.expect(v_payment.from_client_id, ut_common_pack.c_error_msg_test_failed).to_equal(v_from_client_id);
        ut.expect(v_payment.to_client_id, ut_common_pack.c_error_msg_test_failed).to_equal(v_to_client_id);
        ut.expect(v_payment.summa, ut_common_pack.c_error_msg_test_failed).to_equal(v_summa);
        ut.expect(v_payment.currency_id, ut_common_pack.c_error_msg_test_failed).to_equal(v_currency_id);

        ut.expect(v_payment.status, ut_common_pack.c_error_msg_test_failed).to_equal(payment_api_pack.c_status_create);
        ut.expect(v_payment.status_change_reason, ut_common_pack.c_error_msg_test_failed).to_be_null();
-- Проверка работы триггера.

        ut.expect(v_payment.create_dtime_tech, ut_common_pack.c_error_msg_tech_date_failed).to_equal(v_payment.update_dtime_tech);

    end;

-- Проверка "Сброс платежа"
    procedure reset_payment is

        v_payment_id payment.payment_id%type;
        v_reason     payment.status_change_reason%type := ut_common_pack.get_random_reason;
        v_payment    payment%rowtype;
    begin
        v_payment_id := ut_common_pack.create_default_payment();
        payment_api_pack.fail_payment(
                                     p_payment_id => v_payment_id,
                                     p_reason     => v_reason
        );
        v_payment := ut_common_pack.get_payment_info(v_payment_id);
        ut.expect(v_payment.status, ut_common_pack.c_error_msg_test_failed).to_equal(payment_api_pack.c_status_fail);
        ut.expect(v_payment.status_change_reason, ut_common_pack.c_error_msg_test_failed).to_equal(v_reason);

        ut.expect(v_payment.create_dtime_tech, ut_common_pack.c_error_msg_tech_date_failed).not_to_equal(v_payment.update_dtime_tech);
    end;

-- Проверка "Отмена платежа"
    procedure cancel_payment is

        v_payment_id payment.payment_id%type;
        v_reason     payment.status_change_reason%type := ut_common_pack.get_random_reason;
        v_payment    payment%rowtype;
    begin
        v_payment_id := ut_common_pack.create_default_payment();
        payment_api_pack.cancel_payment(
                                       p_payment_id => v_payment_id,
                                       p_reason     => v_reason
        );
        v_payment := ut_common_pack.get_payment_info(v_payment_id);
        ut.expect(v_payment.status, ut_common_pack.c_error_msg_test_failed).to_equal(payment_api_pack.c_status_cancel);
        ut.expect(v_payment.status_change_reason, ut_common_pack.c_error_msg_test_failed).to_equal(v_reason);

    end;

-- Проверка "Успешное завершение платежа"
    procedure successful_payment is
        v_payment_id payment.payment_id%type;
        v_payment    payment%rowtype;
    begin
        v_payment_id := ut_common_pack.create_default_payment();
        payment_api_pack.successful_finish_payment(p_payment_id => v_payment_id);
        v_payment := ut_common_pack.get_payment_info(v_payment_id);
        ut.expect(v_payment.status, ut_common_pack.c_error_msg_test_failed).to_equal(payment_api_pack.c_status_successful);

    end;

-- проверка функционала по глобальному отключению проверок. Операция удаления платежа
    procedure delete_payment_with_direct_dml_and_enabled_manual_change is
        v_payment_id payment.payment_id%type := ut_common_pack.c_non_existing_payment_id;
    begin
        delete from payment p
        where
            p.payment_id = v_payment_id;

    end;

-- Проверка функционала по глобальному отключению проверок. Операция изменения платежа
    procedure update_payment_with_direct_dml_and_enabled_manual_change is
        v_payment_id payment.payment_id%type := ut_common_pack.c_non_existing_payment_id;
    begin
        update payment p
        set
            p.status = payment_api_pack.c_status_successful
        where
            p.payment_id = v_payment_id;

    end;


-- Негативные Unit-тесты

-- Проверка "Отмена платежа"
    procedure cancel_payment_with_empty_reason_should_fail is

        v_payment_id payment.payment_id%type := null;
        v_reason     payment.status_change_reason%type := ut_common_pack.get_random_reason;
    begin
        payment_api_pack.cancel_payment(
                                       p_payment_id => v_payment_id,
                                       p_reason     => v_reason
        );
    end;

-- Проверка удаления платежа через delete
    procedure direct_payment_delete_should_fail is
        v_payment_id payment.payment_id%type := ut_common_pack.c_non_existing_payment_id;
    begin
        delete from payment p
        where
            p.payment_id = v_payment_id;

    end;

-- Проверка "Платеж создан с пустым payment_detail"
    procedure create_payment_with_null_payment_detail is

        v_payment_detail t_payment_detail_array;
        v_payment_id     payment.payment_id%type;
        v_current_dtime  payment.create_dtime%TYPE := systimestamp;
        v_from_client_id payment.from_client_id%type := ut_common_pack.create_default_client();
        v_to_client_id   payment.to_client_id%type := ut_common_pack.create_default_client();
        v_summa          payment.summa%type := ut_common_pack.get_random_payment_summa();
        v_currency_id    payment.currency_id%type := ut_common_pack.get_random_payment_currency_id();
    begin
        v_payment_id := payment_api_pack.create_payment(
                                                       p_payment_detail => v_payment_detail,
                                                       p_current_dtime  => v_current_dtime,
                                                       p_summa          => v_summa,
                                                       p_currency_id    => v_currency_id,
                                                       p_from_client_id => v_from_client_id,
                                                       p_to_client_id   => v_to_client_id
                        );

    end;

-- Проверка "Сброс платежа"
    procedure reset_payment_with_null_payment_id is
        v_payment_id payment.payment_id%type;
        v_reason     payment.status_change_reason%type := ut_common_pack.get_random_reason;
    begin
        payment_api_pack.fail_payment(
                                     p_payment_id => v_payment_id,
                                     p_reason     => v_reason
        );
    end;

-- Проверка "Успешное завершение платежа"
    procedure successful_finish_payment_with_null_payment_id is
        v_payment_id payment.payment_id%type;
    begin
        payment_api_pack.successful_finish_payment(p_payment_id => v_payment_id);
    end;

-- Негативные Unit-тесты на проверку триггеров

-- Проверка запрета вставки в payment не через API
    procedure direct_payment_insert_should_fail is
        v_payment_id payment.payment_id%type := ut_common_pack.c_non_existing_payment_id;
    begin
        insert into payment (
            payment_id,
            status
        ) values (
            v_payment_id,
            payment_api_pack.c_status_create
        );

    end;

-- Проверка запрета обновления в payment не через API
    procedure direct_payment_update_should_fail is
        v_payment_id payment.payment_id%type := ut_common_pack.c_non_existing_payment_id;
    begin
        update payment p
        set
            p.status = payment_api_pack.c_status_successful
        where
            p.payment_id = v_payment_id;

    end;

-- Негативный тест на отсутствие объекта
    procedure cancel_non_existing_payment is

        v_payment_id payment.payment_id%type := ut_common_pack.c_non_existing_payment_id;
        v_reason     payment.status_change_reason%type := ut_common_pack.get_random_reason;
    begin
        payment_api_pack.cancel_payment(
                                       p_payment_id => v_payment_id,
                                       p_reason     => v_reason
        );
    end;

-- Негативный тест на попытку изменения статуса платежа, уже находящегося в финальном статусе
    procedure change_payment_status_in_already_final_status is
        v_payment_id payment.payment_id%type;
        v_reason     payment.status_change_reason%type := ut_common_pack.get_random_reason;
    begin
        v_payment_id := ut_common_pack.create_default_payment();
        payment_api_pack.successful_finish_payment(p_payment_id => v_payment_id);
        payment_api_pack.cancel_payment(
                                       p_payment_id => v_payment_id,
                                       p_reason     => v_reason
        );
    end;

end ut_payment_api_pack;
/