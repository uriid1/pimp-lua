--- Модуль для pretty-print таблиц и небольшого дебагинга
-- @module pimp
local config = require('pimp.config')
local write = require('pimp.write')
local color = require('pimp.color')
local constructor = require('pimp.constructor')
local prettyPrint = require('pimp.pretty-print')
local makePath = require('pimp.utils.makePath')
local plog = require('pimp.log')

local DEFAULT_MAX_SEEN = config.pimp.max_seen
local DEFAULT_PREFIX = config.pimp.prefix
local DEFAULT_SEPARATOR = config.pimp.separator

local getlocal = debug.getlocal
local getinfo = debug.getinfo
local getupvalue = debug.getupvalue
local getfenv = debug.getfenv

local pimp = {
  prefix = config.pimp.prefix,
  separator = config.pimp.separator,
  log = plog,
  color = color,
}

-- Поиск имени переменной, по её значению
--
local function findVarName(value, level)
  if not config.pimp.find_local_name then
    local __type = type(value)
    if not (
        __type == 'function' or
        __type == 'thread'   or
        __type == 'table'    or
        __type == 'userdata'
      )
    then
      return nil, nil
    end
  end

  level = level or 2
  local stack = {}
  local isLocal = false

  -- Поиск среди локальных переменных
  local i = 1
  while true do
    local name, val = getlocal(level, i)
    if not name then
      break
    end
    if val == value then
      table.insert(stack, name)
    end
    i = i + 1
  end

  if stack[1] then
    isLocal = true
    return stack[#stack], isLocal
  end

  -- Поиск среди нелокальных переменных
  --
  local func = getinfo(level, 'f').func
  for i = 1, DEFAULT_MAX_SEEN do
    local name, val = getupvalue(func, i)
    if not name then
      break
    end
    if val == value then
      isLocal = true
      return name, isLocal
    end
  end

  -- Поиск в окружении
  local env = getfenv and getfenv(level) or _ENV or _G
  for name, val in pairs(env) do
    if val == value then
      return name, isLocal
    end
  end

  return nil, isLocal
end

-- Получение аргументов функции
local function getFuncArgsStr(level, nparams)
  local result = ''
  for i = 1, nparams do
    local name, value = getlocal(level, i)
    if not name then
      break
    end

    -- Проверка аргумента на метатаблицу
    local __type = type(value)
    local __mt = getmetatable(value)
    -- Строки определяются как метатаблицы
    if __mt and __type ~= 'string' then
      __type = 'metatable'
    end

    if __type == 'string' then
      value = tostring(value)
      value = '['..value:len()..' byte]'
    elseif
      __type == 'table'     or
      __type == 'metatable' or
      __type == 'userdata'  or
      __type == 'cdata'     or
      __type == 'thread'
    then
      value = '['..__type..']'
    else
      value = tostring(value)
    end

    result = result..name..': '..value

    if i ~= nparams then
     result = result..', '
    end
  end

  return result
end

-- Получение стека вызываемых функций
local function getCallStack(level)
  level = level or 2
  local stack = {}

  for debugLevel = level, DEFAULT_MAX_SEEN do
    local info = getinfo(debugLevel)

    if info == nil then
      break
    end

    if info.name ~= nil then
      local funcName = info.name
      local funcArgs = ''
      local visibilityLabel = ''

      if config.pimp.show_visibility then
        if info.namewhat ~= '' then
          visibilityLabel = info.namewhat..' '
        end
      end

      if info.isvararg then
        if info.nparams == 0 then
          funcArgs = '(...)'
        elseif info.nparams > 0 then
          funcArgs = '('..getFuncArgsStr(debugLevel+1, info.nparams)..', ...)'
        end
      else
        if info.nparams == 0 then
          funcArgs = '()'
        elseif info.nparams > 0 then
          funcArgs = '('..getFuncArgsStr(debugLevel+1, info.nparams)..')'
        end
      end
      funcName = funcName..funcArgs

      table.insert(stack,
        color(color.scheme.visibility, visibilityLabel)..color(color.brightMagenta, funcName)
      )
    end
  end

  -- Возвращается только функция, из которой произошел вызов
  if config.pimp.show_full_call_stack == false then
    return stack[2] or ''
  end

  -- Восстановление последовательности вызова
  -- исключая вызов pimp
  local result = ''
  if config.pimp.show_call_stack_ladder == false then
    for i = #stack, 2, -1 do
      if i == 2 then
        result = result .. stack[i]
      else
        result = result .. stack[i] .. pimp.separator
      end
    end
  else
    result = ''
    for i = #stack, 2, -1 do
      if i == 2 then
        result = result .. string.rep('  ', #stack - i) .. stack[i]
      else
        result = result .. string.rep('  ', #stack - i) .. stack[i] .. pimp.separator..'\n'
      end
    end
  end

  return result
end

function pimp:debug(...)
  if not config.pimp.output then
    return ...
  end

  local level = 2
  local info = getinfo(level, 'lS')
  local callpos = makePath(info)..':'..info.currentline
  local prefix = self.prefix..self.separator

  local varargsCompiled = {}
  for i = 1, select('#', ...) do
    local argValue = select(i, ...)
    local argType = type(argValue)
    local argName, isLocal = findVarName(argValue, level+1)
    local obj = constructor(argType, argValue, argName)

    obj:setShowType(config.pimp.show_type)

    local visibilityLabel = ''
    if config.pimp.show_visibility then
      if isLocal ~= nil then
        visibilityLabel = isLocal and 'local ' or 'global '
        visibilityLabel = color(color.scheme.visibility, visibilityLabel)
      end
    end

    if argType == 'table' then
      prettyPrint:setShowType(config.pimp.show_type)
      prettyPrint:setShowTableAddr(config.pimp.show_table_addr)
      obj:setShowTableAddr(config.pimp.show_table_addr)

      table.insert(varargsCompiled, visibilityLabel..obj:compile()..prettyPrint(argValue))
    else
      table.insert(varargsCompiled, visibilityLabel..obj:compile())
    end
  end

  local stackStr = getCallStack(level)
  local result = table.concat(varargsCompiled, ', ')

  write(
    prefix
    .. callpos  .. ': '
    .. (stackStr == '' and '' or stackStr..': ')
    .. result
  )

  return ...
end

--- Print simple text
-- @param text Text
function pimp.msg(text)
  local level = 2
  local info = getinfo(level)

  local linepos = info.currentline
  local filename = makePath(info)

  local message = ('[%s] %s:%s %s'):format(
    color(color.brightGreen, os.date("%H:%M:%S")),
    filename, linepos,
    color(color.brightYellow, tostring(text))
  )

  write(message)
end

--- Set prefix and separator
-- @param param Table { prefix='cool', sep='->' }
function pimp:setPrefix(param)
  if param.prefix then
    self.prefix = tostring(param.prefix)
  end
  if param.sep then
    self.separator = tostring(param.sep)
  end

  return self
end

--- Reset prefix
function pimp:resetPrefix()
  self.prefix = DEFAULT_PREFIX
  self.separator = DEFAULT_SEPARATOR

  return self
end

--- Enable debug output
function pimp:disable()
  if config.pimp.global_disable then
    return self
  end

  config.pimp.output = false
  return self
end

--- Disable debug output
function pimp:enable()
  if config.pimp.global_disable then
    return self
  end

  config.pimp.output = true
  return self
end

--
function pimp:globalDisable()
  config.pimp.global_disable = true
  config.pimp.output = false

  return self
end

--- Matching path
-- @param str LUA pattert
function pimp:matchPath(str)
  config.pimp.match_path = tostring(str)
  self.log.match_path = config.pimp.match_path

  return self
end

--- Disable full path output
function pimp:disableFullPath()
  config.pimp.full_path = false

  return self
end

--- Enable full path output
function pimp:enableFullPath()
  config.pimp.full_path = true

  return self
end

--- Disable colour output
function pimp:disableColor()
  color.colorise(false)

  return self
end

--- Enable colour output
function pimp:enableColor()
  color.colorise(true)

  return self
end

---
function pimp:enableEscapeNonAscii()
  config.string_format.escape_non_ascii = true

  return self
end

---
function pimp:disableEscapeNonAscii()
  config.string_format.escape_non_ascii = false

  return self
end

--- Enable Visibility
function pimp:enableVisibility()
  config.pimp.show_visibility = true

  return self
end

--- Disable Visibility
function pimp:disableVisibility()
  config.pimp.show_visibility = false

  return self
end

--- Enable show type
function pimp:enableType()
  config.pimp.show_type = true

  return self
end

--- Disable show type
function pimp:disableType()
  config.pimp.show_type = false

  return self
end

--- Enable table address
function pimp:enableTableAddr()
  config.pimp.show_table_addr = true

  return self
end

--- Disable table address
function pimp:disableTableAddr()
  config.pimp.show_table_addr = false

  return self
end

--- Enable full call stack"
function pimp:enableFullCallStack()
  config.pimp.show_full_call_stack = true

  return self
end

--- Disable full call stack
function pimp:disableFullCallStack()
  config.pimp.show_full_call_stack = false

  return self
end

--- Return table with pretty-print
-- without config.pimp.output
function pimp.pp(t)
  prettyPrint:setShowType(false)
  prettyPrint:setShowTableAddr(false)
  return prettyPrint(t)
end

--- Return table with pretty-print
-- without color and config.pimp.output
function pimp.ppnc(t)
  local use_color = config.color.use_color
  prettyPrint:setShowType(false)
  prettyPrint:setShowTableAddr(false)
  color.colorise(false)
  local data = prettyPrint(t)
  color.colorise(use_color)
  return data
end

--
function pimp.getLocalEnv(level)
  level = level or 2
  local i = 1
  local env = {}
  while true do
    local name, value = getlocal(level, i)
    if not name then
      break
    end
    env[name] = value
    i = i + 1
  end

  return env
end

-- Experimental
--
function pimp:enableFindLocalName()
  config.pimp.find_local_name = true

  return self
end

function pimp:disableFindLocalName()
  config.pimp.find_local_name = true

  return self
end

function pimp:enableCallStackLadder()
  config.pimp.show_call_stack_ladder = true

  return self
end

function pimp:disableCallStackLadder()
  config.pimp.show_call_stack_ladder = false

  return self
end

setmetatable(pimp, { __call = pimp.debug })

return pimp
