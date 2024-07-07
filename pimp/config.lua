--- Конфигурационный файл модуля
--
local config = {
  -- Основные параметры
  pimp = {
    -- Вывод текста
    output = true,
    -- Использовать полные пути до фалов
    full_path = true,
    -- Обрезать полный путь до заданного регулярного выражения
    match_path = '',
    --
    show_visibility = false,
    show_type = false,
    show_table_addr = false,
    show_full_functions_stack = true,
  },

  -- Параметры претти печати таблиц
  pretty_print = {
    -- Символ отступов
    tab_char = ' ',
    -- Отображать типы
    show_type = true,
    -- Отображать адреса таблиц
    show_table_addr = false,
  },

  -- Строковые параметры
  string_format = {
    -- Экранировать escape последовательность
    escape_controls = false,
    -- Отображать escape в цвете, заданной темой
    escape_colorize = true,
  },

  -- Параметры логирования
  log = {
    -- Выходной файл
    outfile = 'log.txt',
    -- Логировать с учетом цвета
    usecolor = false,
    -- Игнорировать определенные методы логирования
    ignore = {},
    --
    match_path = '',
  },

  -- Использование цветовой темы
  color = {
    use_color = true,
  }
}

return config
