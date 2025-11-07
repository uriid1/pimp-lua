--
-- Конфигурационный файл
--
local config = {
  -- Отступы
  indent = 2,

  -- Префикс и разделитель
  prefix = 'p',
  separator = ' ➜ ',

  -- Глубина захода в таблицу
  depth = 100,
  -- Глубина на вывод массива
  depth_array_limit = 100,
  -- Максимальное количество элементов выводить из таблицы
  -- 0 для вывода всех
  max_items = 10,
  -- Ограничения на вхождения, для поиска локальных/глобальных переменных,
  lookup_limit = 10000,
  -- Максимальная длина строки для вывода
  max_string_length = 1000,

  -- Раскрашивать lua паттерны
  pattern_colorize = true,
  -- Эскейпинг не ascii последовательности (юникод например)
  escape_non_ascii = false,
  -- Раскрашивать escape последовательности
  escape_controls = true,

  show_address = false,
  --
  show_full_call_stack = true,
  --
  show_call_stack_ladder = true,
  --
  find_local_name = true,

  -- Поддержка цветов
  has_colors = (function()
    local term = os.getenv('TERM')
    if term and (term == 'xterm' or term:find'-256color$') then
      return true
    end

    return false
  end),
}

return config
