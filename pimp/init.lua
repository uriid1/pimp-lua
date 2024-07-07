--- Модуль для претти принта таблиц и небольшого дебагинга
-- @module pimp
local config = require('pimp.config')
local write = require('pimp.write')
local color = require('pimp.color')
local constructor = require('pimp.constructor')
local prettyPrint = require('pimp.pretty-print')
local makePath = require('pimp.utils.makePath')
local plog = require('pimp.log')

local DEFAULT_PREFIX = 'p'
local DEFAULT_PREFIX_SEP = ' ➜ '
local DEFAULT_MAX_SEEN = 1000

local pimp = {
  prefix = DEFAULT_PREFIX,
  prefix_sep = DEFAULT_PREFIX_SEP,
  log = plog,
  color = color,
}

-- Хеширование найденных адресов
--
local seenArg = {}
local function seenAdd(addr, linepos, name)
  if seenArg[addr] then
    seenArg[addr][linepos] = name
    return name
  end

  seenArg[addr] = {}
  seenArg[addr][linepos] = name

  return name
end

local function seenExists(addr, linepos)
  if seenArg[addr] and seenArg[addr][linepos] then
    return true
  end

  return false
end
--

-- Поиск имени таблицы, функции,... по адресу
--
local function findNameByAddr(addr, __type, linepos, level)
  -- DEBUG
  if not (
      __type == 'function' or
      __type == 'thread'   or
      __type == 'table'    or
      __type == 'userdata'

      -- Testing
      -- __type == 'cdata'
    )
  then
    return nil, nil
  end

  if seenExists(addr, linepos) then
    return seenArg[addr][linepos]
  end

  -- Find local name by addr
  for i = 1, DEFAULT_MAX_SEEN do
    local name, value = debug.getlocal(level, i)
    if not name and not value then
      break
    end

    if value == addr then
      return seenAdd(addr, linepos, name), true
    end
  end

  -- Find global name by addr
  for name, value in pairs(_G) do
    if value == addr then
      return seenAdd(addr, linepos, name), false
    end
  end

  return nil, nil
end
--

---
-- Output debugging information
-- @param ... any Arguments to be printed
-- @return ... The passed arguments
function pimp:debug(...)
  if not config.pimp.output then
    return ...
  end

  local argsCount = select('#', ...)
  local prefix = self.prefix..self.prefix_sep

  -- Get full information about the calling location
  local level = 2

  local infunc = ''
  do
  for debugLevel = level, DEFAULT_MAX_SEEN do
    local info = debug.getinfo(debugLevel)

    -- Debug
    -- write(prettyPrint(info))

    if info == nil then
      break
    end

    if info.namewhat ~= '' then
      local funcName = info.name
      local funcArgs = ''
      local visibilityLabel = ''

      if config.pimp.show_visibility then
        if info.namewhat == 'local' or
          info.namewhat == 'global'
        then
          visibilityLabel = info.namewhat..' '
        end
      end

      if info.linedefined > 0 then
        if info.nparams > 0 then
          -- Get local func args
          for i = 1, info.nparams do
            local name, value = debug.getlocal(level, i)
            if not name and not value then
              break
            end

            local __type = type(value)
            local __mt = getmetatable(value)
            if __mt then
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

            funcArgs = funcArgs..name..': '..value
            if i ~= info.nparams then
             funcArgs = funcArgs..', '
            end
          end

          funcName = funcName..'('..funcArgs

          if info.isvararg then
            funcName = funcName..', ...'
          end

          funcName = funcName..')'
        else
          if info.isvararg then
            funcName = funcName..'(...)'
          else
            funcName = funcName..'()'
          end
        end
      elseif info.nparams == 0 then
        -- 0 params
        funcName = funcName..'()'
      else
        funcName = funcName..'(?)'
      end

      infunc = infunc
        ..(debugLevel == level and 'in ' or '➜ ')
        ..color(color.scheme.visibility, visibilityLabel)
        ..color(color.brightMagenta, funcName)..': '
    end

    if config.pimp.show_full_functions_stack == false then
      break
    end
  end
  end -- do

  local info = debug.getinfo(level)
  local linepos = info.currentline
  local filename = makePath(info)
  local callpos = filename..':'..linepos

  -- Parse
  local data = {}
  for i = 1, argsCount do
    local value = select(i, ...)
    local argType = type(value)
    local argName, isLocal = findNameByAddr(value, argType, linepos, level + 1)
    local funcArgs = nil

    local obj = constructor(argType, value, argName, funcArgs)

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

      table.insert(data, visibilityLabel..obj:compile()..prettyPrint(value))
    else
      table.insert(data, visibilityLabel..obj:compile())
    end
  end

  local result = table.concat(data, ', ')

  local delimiter = ' '
  if infunc == '' then
    delimiter = ': '
  end

  write(prefix..callpos..delimiter..infunc..result)

  -- Возвращение изначально переданных аргументов
  return ...
end

--- Print simple text
-- @param text Text
function pimp.msg(text)
  local level = 2
  local info = debug.getinfo(level)

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
    self.prefix_sep = tostring(param.sep)
  end

  return self
end

--- Reset prefix
function pimp:resetPrefix()
  self.prefix = DEFAULT_PREFIX
  self.prefix_sep = DEFAULT_PREFIX_SEP

  return self
end

--- Enable debug output
function pimp:disable()
  config.pimp.output = false

  return self
end

--- Disable debug output
function pimp:enable()
  config.pimp.output = true

  return self
end

--- Matching path
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

--- Enable full functions stack called
function pimp:enableFullFunctionsStack()
  config.pimp.show_full_functions_stack = true

  return self
end

--- Disable full functions stack called
function pimp:disableFullFunctionsStack()
  config.pimp.show_full_functions_stack = false

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

setmetatable(pimp, { __call = pimp.debug })

return pimp
