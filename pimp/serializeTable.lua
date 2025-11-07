local config = require('pimp3.config')
local colors = require('pimp3.colors')
local serializeValue = require('pimp3.serializeValue')
local term = require('pimp3.term')

local colorize = colors.colorize
local c_circular = colors.scheme.circular

-- Функция для оценки визуальной длины значения (без ANSI escape codes)
local function getValueLength(str)
  -- Убираем ANSI escape sequences для подсчета реальной длины
  local clean = tostring(str):gsub('\27%[[0-9;]*m', '')
  return #clean
end

-- Сериализация значения во временный буфер для измерения длины
local function serializeToString(value, serializeValueFunc)
  local StringBuffer = require('pimp3.StringBuffer')
  local temp_buffer = StringBuffer.new()
  serializeValueFunc(value, temp_buffer)
  return temp_buffer:toString()
end

local function serializeTable(tbl, buffer, callback, level, visited)
  level = level or 0
  visited = visited or {}

  if level >= config.depth then
    buffer:append(colorize('< ... Out of depth >', colors.depth))
    return
  end

  if visited[tbl] then
    buffer:append(colorize('<circular>', c_circular))
    return
  end

  visited[tbl] = true

  if not next(tbl) then
    buffer:append('{}')
    return
  end

  buffer:appendMultiple('{', '\n')

  local arr_len = #tbl
  local is_array = arr_len > 0

  if is_array then
    local term_width = term.getSize()
    local indent = (level + 1) * config.indent

    -- Собираем все элементы массива и вычисляем их длины
    local items = {}
    local max_length = 0
    local display_limit = math.min(arr_len, config.depth_array_limit)

    for i = 1, display_limit do
      local value = tbl[i]
      if value ~= nil then
        local item_str = serializeToString(value, serializeValue)
        local visual_length = getValueLength(item_str)

        table.insert(items, {
          str = item_str,
          length = visual_length
        })

        if visual_length > max_length then
          max_length = visual_length
        end
      end
    end

    -- Вычисляем сколько элементов помещается в строку с учетом выравнивания
    local item_width = max_length + 2 -- +2 для ", "
    local items_per_line = math.max(1, math.floor((term_width - indent) / item_width))

    -- Проверяем наличие не-числовых ключей
    local has_non_numeric = false
    for key in pairs(tbl) do
      if type(key) ~= 'number' then
        has_non_numeric = true
        break
      end
    end

    -- Выводим элементы с выравниванием
    for i, item in ipairs(items) do
      if (i - 1) % items_per_line == 0 then
        buffer:appendIndent(level + 1)
      end

      -- Используем новый метод appendPadded для выравнивания
      buffer:appendPadded(item.str, max_length, 'right')
      buffer:append(', ')

      -- Перенос строки после каждых items_per_line элементов
      if i % items_per_line == 0 or i == #items then
        buffer:append('\n')
      end
    end

    -- Показываем сообщение о пропущенных элементах
    if display_limit < arr_len then
      buffer:appendIndent(level + 1)
      buffer:append(string.format('< ... %d more items >', arr_len - display_limit))
      buffer:append('\n')
    end

    -- Обработка не-числовых ключей
    if has_non_numeric then
      for key, value in pairs(tbl) do
        if type(key) ~= 'number' then
          buffer:appendIndent(level + 1)
          serializeValue(key, buffer)
          buffer:appendMultiple(' = ')
          serializeValue(value, buffer)
          buffer:appendMultiple(', ', '\n')
        end
      end
    end
  else
    -- Обработка обычных таблиц (хэш-таблиц)
    for key, value in pairs(tbl) do
      buffer:appendIndent(level + 1)

      local key_type = type(key)

      if key_type == 'number' then
        buffer:appendMultiple(
          '[',
          colorize(key, colors.scheme.Number),
          ']'
        )
      elseif key_type == 'string' and key:find('%s') then
        buffer:appendMultiple(
          '["',
          colorize(key, colors.scheme.table_field),
          '"]'
        )
      else
        buffer:append(colorize(key, colors.scheme.table_field))
      end

      buffer:append(' = ')

      local value_type = type(value)

      if value_type == 'table' then
        local nestedTable = tbl[key]
        local itemCount = 0
        local showTable = true

        if config.max_items > 0 then
          for _, _ in pairs(nestedTable) do
            itemCount = itemCount + 1

            if itemCount > config.max_items then
              showTable = false
              break
            end
          end
        end

        if showTable then
          callback(buffer)
          serializeTable(tbl[key], buffer, callback, level + 1, visited)
        else
          if visited[value] then
            local msg = config.show_address
              and string.format('<circular [%p]>', value)
              or '<circular>'
            buffer:append(colorize(msg, c_circular))
          else
            serializeTable(tbl[key], buffer, callback, level + 1, visited)
          end
        end
      else
        serializeValue(value, buffer, { table = false, level = level + 1 })
      end

      buffer:appendMultiple(',', '\n')
    end
  end

  buffer:appendIndent(level)
  buffer:append('}')

  visited[tbl] = nil

  callback(buffer)
end

return serializeTable
