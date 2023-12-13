create or replace PACKAGE BODY COMMON_PACK IS

  -- включен ли флажок возможности "ручных" изменений
  g_enable_manual_changes boolean := false;

  -- Включение/отключение разрешения менять данные объектов вручную
  PROCEDURE enable_manual_changes IS
  BEGIN
    g_enable_manual_changes := true;
  END enable_manual_changes;

  PROCEDURE disable_manual_changes IS
  BEGIN
    g_enable_manual_changes := false;
  END disable_manual_changes;

  -- Разрешены ли ручные изменения на глобальном уровне сессии
  FUNCTION is_manual_changes_allowed RETURN BOOLEAN IS
  BEGIN
    RETURN g_enable_manual_changes;
  END is_manual_changes_allowed;

END COMMON_PACK;
/