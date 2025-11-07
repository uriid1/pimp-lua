local config = require('pimp3.config')
local serializeTable = require('pimp3.serializeTable')
local serializeValue = require('pimp3.serializeValue')
local StringBuffer = require('pimp3.StringBuffer')
local colors = require('pimp3.colors')
local term = require('pimp3.term')

local colorize = colors.colorize

---
-- Форматирует и выводит значения с подсветкой синтаксиса
-- @param ... - любые значения для вывода
-- @return ... - возвращает все переданные аргументы (для цепочки вызовов)
local function pimp(...)
  local arg_count = select('#', ...)

  -- Если нет аргументов, просто выводим пустую строку
  if arg_count == 0 then
    io.write('\n')
    return
  end

  local buffer = StringBuffer.new()
  local term_info = term.getInfo()

  -- Определяем, нужно ли использовать цвета
  local use_colors = config.colors and term_info.has_colors

  -- Временно отключаем цвета если терминал не поддерживает
  local original_colors_setting = config.colors
  if not use_colors then
    config.colors = false
  end

  for i = 1, arg_count do
    local arg_value = select(i, ...)
    local arg_type = type(arg_value)

    -- Выводим префикс с временем (только если включены цвета)
    if use_colors and config.show_timestamp then
      buffer:appendMultiple(
        '[',
        colorize(os.date('%H:%M:%S'), colors.scheme.date),
        '] '
      )
    end

    -- Выводим префикс
    if config.prefix and config.prefix ~= '' then
      buffer:append(config.prefix)
      if config.separator and config.separator ~= '' then
        buffer:append(config.separator)
      end
    end

    -- Сериализуем значение в зависимости от типа
    if arg_type == 'table' then
      serializeTable(arg_value, buffer, function(_buffer)
        io.write(_buffer:toString())
        _buffer:clear()
      end)
    else
      -- Для не-таблиц используем serializeValue
      serializeValue(arg_value, buffer)
      io.write(buffer:toString())
      buffer:clear()
    end

    -- Добавляем разделитель между аргументами (если их несколько)
    if i < arg_count then
      io.write('\t')  -- или config.args_separator
    end
  end

  io.write('\n')
  io.flush()  -- Важно для корректного вывода в некоторых случаях

  -- Восстанавливаем настройку цветов
  config.colors = original_colors_setting

  return ...
end

-- ---
-- -- Выводит без временной метки и префикса
-- pimp.plain = function(...)
--   local original_prefix = config.prefix
--   local original_timestamp = config.show_timestamp

--   config.prefix = ''
--   config.show_timestamp = false

--   pimp(...)

--   config.prefix = original_prefix
--   config.show_timestamp = original_timestamp

--   return ...
-- end

-- ---
-- -- Выводит с кастомным префиксом
-- pimp.with = function(prefix)
--   return function(...)
--     local original_prefix = config.prefix
--     config.prefix = prefix

--     pimp(...)

--     config.prefix = original_prefix
--     return ...
--   end
-- end

return pimp
