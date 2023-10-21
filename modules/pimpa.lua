-- Модуль пимпа
--
local pp = require 'modules.pretty-print'
local color = require 'modules.color'
local tocolor = color.tocolor

local ice_cream = {
  prefix = nil,
  module_name = 'p',
  colorize = true,
}

-- Поиск переданных в функцию аргументов
local function find_call(filepath, call_line)
  local i = 0
  for line in io.lines(filepath) do
    i = i + 1
    if i == call_line then
      local fdata = line:match(ice_cream.module_name..'%((.+)%)')
      return fdata
    end
  end
end

local function type_constructor(arg, args_count)
  local arg_type = type(arg)

  if arg_type == 'table' then
    -- Передана таблица
    if args_count then
      if args_count > 1 then
        return tocolor(tostring(arg), 'table_addr')
      end
    end

    -- Претти принт таблицы
    return pp:wrap(arg)
  elseif arg_type == 'number' then
    -- Передано число
    return tocolor(tostring(arg), arg_type)..': [number]'
  elseif arg_type == 'function' then
    -- Передан адрес функции
    return tocolor(tostring(arg), arg_type)
  elseif arg_type == 'string' then
    -- Передана строка
    return tocolor(arg)..': [length '..tostring(#arg)..']'
  elseif arg_type == 'thread' then
    -- Передана сопрограмма
    return tocolor(tostring(arg), arg_type)
  elseif arg_type == 'boolean' then
    -- Передано булевое значение
    return tocolor(tostring(arg), arg_type)..': [boolean]'
  else
    -- Передано nil, cdata или неизвестный тип
    return tocolor(tostring(arg), arg_type)..': [type undefended]'
  end
end

function ice_cream:debug(...)
  local args = {...}

  -- Установка префикса исходя из имени -
  -- загруженного модуля
  if not self.prefix then
    local info = debug.getinfo(1, 'n')
    self.prefix = info.name..'| '
    self.module_name = info.name
  end

  -- Получить информацию о месте вызова
  -- S - source, short_src, what, linedefined, lastlinedefined
  -- L - currentline
  local info = debug.getinfo(2, 'Sl')

  local linepos = info.currentline
  local filename = info.short_src
  local filepath = info.source:match('@(.+)')
  local callpos = filename..':'..linepos

  -- Не передали аргументов
  if #args == 0 then
    io.write(self.prefix..callpos, '\n')
    return ...
  end

  -- Обработка типа cdata
  local type = info.what
  if type == 'C' then
    io.write(self.prefix..table.concat(args, ', '), '\n')
    return ...
  end

  -- Поиск аргументов
  local callname = find_call(filepath, linepos)

  if #args == 1 then
    -- Если первым аргументом был вызов функции
    if callname:match('.+%(.+%)') ~= nil then
      local fmt_str = '%s%s: %s: %s\n'
      io.write(fmt_str:format(self.prefix, callpos, tocolor(callname, 'custom_func'), ...))
      return ...
    end

    -- Определение первого аргумента
    local res = type_constructor(args[1])
    local fmt_str = '%s%s: %s\n'
    io.write(fmt_str:format(self.prefix, callpos, res))
    return ...
  end

  -- Обработка переменного числа аргументов
  local data = {}
  for i = 1, #args do
    local arg = args[i]
    local res = type_constructor(arg, #args)
    table.insert(data, res)
  end

  local fmt_str = '%s%s: %s\n'
  io.write(fmt_str:format(self.prefix, callpos, table.concat(data, ', ')))
  return ...
end

-- Установка вызова debug функции
-- при попытки вызвать таблицу как функцию
setmetatable(ice_cream, { __call = ice_cream.debug })

return ice_cream
