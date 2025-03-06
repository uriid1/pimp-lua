-- Конфигурационный файл модуля
local config = {
  -- Основные параметры
  pimp = {
    prefix = 'p',
    separator = ' ➜ ',
    -- Ограничения на вхождения, для поиска локальных/глобальных переменных, для печати массива, для вхождений в таблицы
    max_seen = 10000,
    -- Вывод текста, регулируется :disable, :enable
    output = true,
    -- Глобальное отключение вывода
    global_disable = false,
    -- Использовать полные пути до фалов
    full_path = true,
    -- Обрезать полный путь до заданного регулярного выражения
    match_path = '',
    -- Флаги отображения
    show_visibility = false,
    show_type = false,
    show_table_addr = false,
    show_full_call_stack = true,
    -- Отображение лесенкой вывода вызываемых функций
    show_call_stack_ladder = true,
    -- Отображать числа как hex
    decimal_to_hexadecimal = false,
    -- Экспериментальные флаги
    --
    -- Флаг отвечает за поиск локальных переменных -
    -- WARNING: флаг не гарантирует, что найденное имя переменной -
    -- будет соответствовать значению этой переменной.
    -- Это связано из-за особенностей lua, например полученные varargs -
    -- из функции никак не совместить с именем локальной переменой.
    -- Точно так же, как и локальные переменные и переменные апвелью с -
    -- одинаковыми значениями.
    --[[ Пример
      local function test(num)
        local test = 100
        p(num)
      end
      test(100)
    ]]
    find_local_name = false,
  },

  -- Параметры красивой-печати таблиц
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
    escape_controls = true,
    -- Экранирование всех не ASCII символов
    escape_non_ascii = false,
    -- Отображать escape в цвете, заданной темой
    escape_colorize = true,
    -- Классы lua в цвет
    patterns_colorize = true,
  },

  -- Параметры синхронного логирования
  log = {
    -- Выходной файл
    outfile = 'log.txt',
    -- Логировать с учетом цвета
    use_color = false,
    -- Игнорировать определенные методы логирования
    ignore = {},
    --
    match_path = '',
  },

  -- Использование цветовой темы
  color = {
    use_color = (function()
      local term = os.getenv('TERM')
      if term and (term == 'xterm' or term:find'-256color$') then
        return true
      else
        return false
      end
    end),
  }
}

return config
