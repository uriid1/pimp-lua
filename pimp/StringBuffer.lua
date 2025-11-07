--
-- Custom string buffer implementation
--
local config = require('pimp3.config')

local StringBuffer = {}
StringBuffer.__index = StringBuffer

-- Кэш для отступов (избегаем повторного создания одинаковых строк)
local indent_cache = {}

local function getIndent(level)
  local size = level * config.indent

  if not indent_cache[size] then
    indent_cache[size] = string.rep(' ', size)
  end

  return indent_cache[size]
end

function StringBuffer.new()
  return setmetatable({
    buffer = {},
    length = 0
  }, StringBuffer)
end

function StringBuffer:append(str)
  if str == nil then
    return self
  end

  local s = tostring(str)
  self.length = self.length + 1
  self.buffer[self.length] = s

  return self
end

function StringBuffer:appendLine(str)
  if str ~= nil then
    self:append(str)
  end
  self:append('\n')
  return self
end

function StringBuffer:appendIndent(level)
  self:append(getIndent(level))
  return self
end

-- Метод для добавления нескольких строк за раз (оптимизация)
function StringBuffer:appendMultiple(...)
  local args = {...}
  local n = select('#', ...)

  for i = 1, n do
    if args[i] ~= nil then
      self.length = self.length + 1
      self.buffer[self.length] = tostring(args[i])
    end
  end

  return self
end

-- Метод для добавления с паддингом (для выравнивания)
function StringBuffer:appendPadded(str, width, align)
  local s = tostring(str)
  local len = #s:gsub('\27%[[0-9;]*m', '')  -- длина без ANSI кодов
  local padding = width - len

  if padding > 0 then
    if align == 'right' then
      self:append(string.rep(' ', padding))
      self:append(s)
    elseif align == 'center' then
      local left_pad = math.floor(padding / 2)
      local right_pad = padding - left_pad
      self:append(string.rep(' ', left_pad))
      self:append(s)
      self:append(string.rep(' ', right_pad))
    else  -- left or default
      self:append(s)
      self:append(string.rep(' ', padding))
    end
  else
    self:append(s)
  end

  return self
end

-- Получить текущую длину буфера (количество элементов)
function StringBuffer:size()
  return self.length
end

-- Проверка, пуст ли буфер
function StringBuffer:isEmpty()
  return self.length == 0
end

function StringBuffer:clear()
  -- Более эффективная очистка
  for i = 1, self.length do
    self.buffer[i] = nil
  end
  self.length = 0
  return self
end

function StringBuffer:toString()
  return table.concat(self.buffer, '', 1, self.length)
end

-- Метод для получения последнего добавленного элемента (полезно для отладки)
function StringBuffer:peek()
  if self.length > 0 then
    return self.buffer[self.length]
  end
  return nil
end

-- Метод для удаления последнего элемента
function StringBuffer:pop()
  if self.length > 0 then
    local value = self.buffer[self.length]
    self.buffer[self.length] = nil
    self.length = self.length - 1
    return value
  end
  return nil
end

return StringBuffer
