create or replace PACKAGE common_pack IS

    /*
    Автор А.А. Лаптев
    Описание скрипта: общие объекты

    */

    -- Сообщения ошибок
    c_error_msg_empty_field_id CONSTANT VARCHAR2(100 CHAR) := 'ID поля не может быть пустым';
    c_error_msg_empty_field_value CONSTANT VARCHAR2(100 CHAR) := 'Значение поля не может быть пустым';
    c_error_msg_empty_collection CONSTANT VARCHAR2(100 CHAR) := 'Коллекция не содержит данных';
    c_error_msg_empty_object_id CONSTANT VARCHAR2(100 CHAR) := 'ID объекта не может быть пустым';
    c_error_msg_empty_reason CONSTANT VARCHAR2(100 CHAR) := 'Причина не может быть пустой';
    c_error_msg_delete_forbidden CONSTANT VARCHAR2(100 CHAR) := 'Удаление объекта запрещено';
    c_error_msg_manual_changes CONSTANT VARCHAR2(100 CHAR) := 'Изменения должны выполняться только через API';
    c_error_msg_final_state_object CONSTANT VARCHAR2(100 CHAR) := 'Объект в конечном статусе. Изменения невозможны';
    c_error_msg_object_notfound CONSTANT VARCHAR2(100 CHAR) := 'Объект не найден';
    c_error_msg_object_already_locked CONSTANT VARCHAR2(100 CHAR) := 'Объект уже заблокирован';
    c_error_msg_inactive_object CONSTANT VARCHAR2(100 CHAR) := 'Объект в конечном статусе. Изменения невозможны';

    -- Коды ошибок
    c_error_code_invalid_input_parameter CONSTANT NUMBER(10) := -20101;
    c_error_code_delete_forbidden CONSTANT NUMBER(10) := -20102;
    c_error_code_manual_changes CONSTANT NUMBER(10) := -20103;
    c_error_code_final_state_object CONSTANT NUMBER(10) := -20104;
    c_error_code_object_notfound CONSTANT NUMBER(10) := -20105;
    c_error_code_object_already_locked CONSTANT NUMBER(10) := -20106;
    c_error_code_inactive_object CONSTANT NUMBER(10) := -20107;

    -- Объекты исключений
    e_invalid_input_parameter EXCEPTION;
    PRAGMA exception_init ( e_invalid_input_parameter, c_error_code_invalid_input_parameter );
    e_delete_forbidden EXCEPTION;
    PRAGMA exception_init ( e_delete_forbidden, c_error_code_delete_forbidden );
    e_manual_changes EXCEPTION;
    PRAGMA exception_init ( e_manual_changes, c_error_code_manual_changes );
    e_object_notfound EXCEPTION;
    PRAGMA exception_init ( e_object_notfound, c_error_code_object_notfound );
    e_row_locked EXCEPTION;
    PRAGMA exception_init ( e_row_locked, -00054 );
    e_object_already_locked EXCEPTION;
    PRAGMA exception_init ( e_object_already_locked, c_error_code_object_already_locked );
    e_object_already_in_final_state EXCEPTION;
    PRAGMA exception_init ( e_object_already_in_final_state, c_error_code_final_state_object );

    -- Включение/отключение разрешения менять данные объектов вручную
    PROCEDURE enable_manual_changes;

    PROCEDURE disable_manual_changes;

    -- Разрешены ли ручные изменения на глобальном уровне сессии
    FUNCTION is_manual_changes_allowed RETURN BOOLEAN;

END common_pack;
/