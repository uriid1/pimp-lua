--- Module for pretty-printing tables and debugging utilities
-- @module pimp
local config = require('pimp.config')
local write = require('pimp.write')
local color = require('pimp.color')
local constructor = require('pimp.constructor')
local prettyPrint = require('pimp.pretty-print')
local makePath = require('pimp.utils.makePath')
local plog = require('pimp.log')

--- Default configuration constants
local DEFAULT_MAX_SEEN = config.pimp.max_seen
local DEFAULT_PREFIX = config.pimp.prefix
local DEFAULT_SEPARATOR = config.pimp.separator

--- Debug utilities
local getlocal = debug.getlocal
local getinfo = debug.getinfo
local getupvalue = debug.getupvalue
local getfenv = debug.getfenv

--- Main module table
local pimp = {
  prefix = config.pimp.prefix,
  separator = config.pimp.separator,
  log = plog,
  color = color,
}

--- Find variable name by its value
-- @param value The value to find the name for
-- @param level Stack level to search in
-- @return name, isLocal The variable name and whether it's local
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

  -- Search among local variables
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

  -- Search among non-local variables
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

  -- Search in environment
  local env = getfenv and getfenv(level) or _ENV or _G

  if env ~= nil then
    for name, val in pairs(env) do
      if val == value then
        return name, isLocal
      end
    end
  end

  return nil, isLocal
end

--- Get function arguments as a string
-- @param level Stack level
-- @param nparams Number of parameters
-- @return String representation of function arguments
local function getFuncArgsStr(level, nparams)
  local result = ''
  for i = 1, nparams do
    local name, value = getlocal(level, i)
    if not name then
      break
    end

    -- Check if argument has a metatable
    local __type = type(value)
    local __mt = getmetatable(value)
    -- Strings are defined as metatables
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

--- Get call stack of functions
-- @param level Stack level to start from
-- @return Formatted call stack string
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

  -- Return only the function from which the call was made
  if config.pimp.show_full_call_stack == false then
    return stack[2] or ''
  end

  -- Restore call sequence excluding pimp call
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

--- Debug function to print values with context information
-- @param ... Values to debug
-- @return The input values (for chaining)
function pimp:debug(...)
  if not config.pimp.output then
    return ...
  end

  local level = 2
  local info = getinfo(level, 'lS')
  if info == nil then
    level = 1
    info = getinfo(level, 'lS')
  end
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

--- Print simple text message with timestamp
-- @param text Text to print
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
-- @param param Table with prefix and separator { prefix='cool', sep='->' }
-- @return self for method chaining
function pimp:setPrefix(param)
  if param.prefix then
    self.prefix = tostring(param.prefix)
  end
  if param.sep then
    self.separator = tostring(param.sep)
  end

  return self
end

--- Reset prefix and separator to defaults
-- @return self for method chaining
function pimp:resetPrefix()
  self.prefix = DEFAULT_PREFIX
  self.separator = DEFAULT_SEPARATOR

  return self
end

--- Disable debug output
-- @return self for method chaining
function pimp:disable()
  if config.pimp.global_disable then
    return self
  end

  config.pimp.output = false
  return self
end

--- Enable debug output
-- @return self for method chaining
function pimp:enable()
  if config.pimp.global_disable then
    return self
  end

  config.pimp.output = true
  return self
end

--- Globally disable pimp calls
-- @return self for method chaining
function pimp:globalDisable()
  config.pimp.global_disable = true
  config.pimp.output = false

  return self
end

--- Set path matching pattern
-- @param str Lua pattern to match paths
-- @return self for method chaining
function pimp:matchPath(str)
  config.pimp.match_path = tostring(str)
  self.log.match_path = config.pimp.match_path

  return self
end

--- Disable full path output
-- @return self for method chaining
function pimp:disableFullPath()
  config.pimp.full_path = false

  return self
end

--- Enable full path output
-- @return self for method chaining
function pimp:enableFullPath()
  config.pimp.full_path = true

  return self
end

--- Disable color output
-- @return self for method chaining
function pimp:disableColor()
  color.colorise(false)

  return self
end

--- Enable color output
-- @return self for method chaining
function pimp:enableColor()
  color.colorise(true)

  return self
end

--- Enable escaping of non-ASCII characters
-- @return self for method chaining
function pimp:enableEscapeNonAscii()
  config.string_format.escape_non_ascii = true

  return self
end

--- Disable escaping of non-ASCII characters
-- @return self for method chaining
function pimp:disableEscapeNonAscii()
  config.string_format.escape_non_ascii = false

  return self
end

--- Enable visibility information display
-- @return self for method chaining
function pimp:enableVisibility()
  config.pimp.show_visibility = true

  return self
end

--- Disable visibility information display
-- @return self for method chaining
function pimp:disableVisibility()
  config.pimp.show_visibility = false

  return self
end

--- Enable type information display
-- @return self for method chaining
function pimp:enableType()
  config.pimp.show_type = true

  return self
end

--- Disable type information display
-- @return self for method chaining
function pimp:disableType()
  config.pimp.show_type = false

  return self
end

--- Enable table address display
-- @return self for method chaining
function pimp:enableTableAddr()
  config.pimp.show_table_addr = true

  return self
end

--- Disable table address display
-- @return self for method chaining
function pimp:disableTableAddr()
  config.pimp.show_table_addr = false

  return self
end

--- Enable full call stack display
-- @return self for method chaining
function pimp:enableFullCallStack()
  config.pimp.show_full_call_stack = true

  return self
end

--- Disable full call stack display
-- @return self for method chaining
function pimp:disableFullCallStack()
  config.pimp.show_full_call_stack = false

  return self
end

--- Return table with pretty-print without respecting output config
-- @param t Table to pretty-print
-- @return Pretty-printed string representation
function pimp.pp(t)
  prettyPrint:setShowType(false)
  prettyPrint:setShowTableAddr(false)
  return prettyPrint(t)
end

--- Return table with pretty-print without color and output config
-- @param t Table to pretty-print
-- @return Pretty-printed string representation without color
function pimp.ppnc(t)
  local use_color = config.color.use_color
  prettyPrint:setShowType(false)
  prettyPrint:setShowTableAddr(false)
  color.colorise(false)
  local data = prettyPrint(t)
  color.colorise(use_color)
  return data
end

--- Get local environment variables
-- @param level Stack level to get locals from
-- @return Table with local variables
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

--- Experimental features section

--- Enable finding local variable names
-- @return self for method chaining
function pimp:enableFindLocalName()
  config.pimp.find_local_name = true

  return self
end

--- End section

--- Disable finding local variable names
-- @return self for method chaining
function pimp:disableFindLocalName()
  config.pimp.find_local_name = false

  return self
end

--- Enable call stack ladder display
-- @return self for method chaining
function pimp:enableCallStackLadder()
  config.pimp.show_call_stack_ladder = true

  return self
end

--- Disable call stack ladder display
-- @return self for method chaining
function pimp:disableCallStackLadder()
  config.pimp.show_call_stack_ladder = false

  return self
end

--- Enable decimal to hexadecimal conversion
-- @return self for method chaining
function pimp:decimalToHexadecimal()
  config.pimp.decimal_to_hexadecimal = true

  return self
end

-- Set metatable to make pimp callable as a function
setmetatable(pimp, { __call = pimp.debug })

return pimp