--- Pretty-printing and debugging utilities.
local config = require('pimp.config')
local write = require('pimp.write')
local color = require('pimp.color')
local prettyPrint = require('pimp.pretty_print')
local makePath = require('pimp.utils.make_path')
local pimpDebug = require('pimp.debug')

local DEFAULT_PREFIX = config.pimp.prefix -- Prefix restored by resetPrefix
local DEFAULT_SEPARATOR = config.pimp.separator -- Separator restored by resetPrefix

local getinfo = debug.getinfo

local pimp = {
  prefix = config.pimp.prefix,
  separator = config.pimp.separator,
  color = color,
}

--- Print values with the call context.
-- Implemented in pimp/debug.lua and attached without a wrapper
-- to keep stack levels of debug.getlocal and getinfo intact.
-- @function pimp:debug
-- @tparam any ... Values to print
-- @treturn any ... Input values unchanged (for chaining)
pimp.debug = pimpDebug.debug

--- Collect local variables at the given stack level.
-- @function pimp.getLocalEnv
-- @tparam ?number level Stack level
-- @treturn table env Name -> value table
pimp.getLocalEnv = pimpDebug.getLocalEnv

--- Print a plain text message with a timestamp.
-- @tparam any text Text to print
function pimp.msg(text)
  local level = 2
  local info = getinfo(level)

  local linepos = info.currentline
  local filename = makePath(info)

  local message = ('[%s] %s:%s %s'):format(
    color(color.brightGreen, os.date('%H:%M:%S')),
    filename, linepos,
    color(color.brightYellow, tostring(text))
  )

  write(message)
end

--- Set the prefix and the separator.
-- @tparam table param Table of the form { prefix = 'cool', sep = '->' }
-- @treturn table self
function pimp:setPrefix(param)
  if type(param) ~= 'table' then
    return self
  end

  if param.prefix then
    self.prefix = tostring(param.prefix)
  end
  if param.sep then
    self.separator = tostring(param.sep)
  end

  return self
end

--- Reset the prefix and the separator to defaults.
-- @treturn table self
function pimp:resetPrefix()
  self.prefix = DEFAULT_PREFIX
  self.separator = DEFAULT_SEPARATOR

  return self
end

--- Disable debug output.
-- @treturn table self
function pimp:disable()
  if config.pimp.global_disable then
    return self
  end

  config.pimp.output = false
  return self
end

--- Enable debug output.
-- @treturn table self
function pimp:enable()
  if config.pimp.global_disable then
    return self
  end

  config.pimp.output = true
  return self
end

--- Disable pimp calls globally.
-- @treturn table self
function pimp:globalDisable()
  config.pimp.global_disable = true
  config.pimp.output = false

  return self
end

--- Set the path matching pattern.
-- @tparam string str Lua pattern to match paths
-- @treturn table self
function pimp:matchPath(str)
  config.pimp.match_path = tostring(str)

  return self
end

--- Disable full path output.
-- @treturn table self
function pimp:disableFullPath()
  config.pimp.full_path = false

  return self
end

--- Enable full path output.
-- @treturn table self
function pimp:enableFullPath()
  config.pimp.full_path = true

  return self
end

--- Disable colored output.
-- @treturn table self
function pimp:disableColor()
  color.colorise(false)

  return self
end

--- Enable colored output.
-- @treturn table self
function pimp:enableColor()
  color.colorise(true)

  return self
end

--- Enable escaping of non-ASCII characters.
-- @treturn table self
function pimp:enableEscapeNonAscii()
  config.string_format.escape_non_ascii = true

  return self
end

--- Disable escaping of non-ASCII characters.
-- @treturn table self
function pimp:disableEscapeNonAscii()
  config.string_format.escape_non_ascii = false

  return self
end

--- Enable the local / global visibility label.
-- @treturn table self
function pimp:enableVisibility()
  config.pimp.show_visibility = true

  return self
end

--- Disable the local / global visibility label.
-- @treturn table self
function pimp:disableVisibility()
  config.pimp.show_visibility = false

  return self
end

--- Enable type labels.
-- @treturn table self
function pimp:enableType()
  config.pimp.show_type = true

  return self
end

--- Disable type labels.
-- @treturn table self
function pimp:disableType()
  config.pimp.show_type = false

  return self
end

--- Enable table address display.
-- @treturn table self
function pimp:enableTableAddr()
  config.pimp.show_table_addr = true

  return self
end

--- Disable table address display.
-- @treturn table self
function pimp:disableTableAddr()
  config.pimp.show_table_addr = false

  return self
end

--- Enable full call stack display.
-- @treturn table self
function pimp:enableFullCallStack()
  config.pimp.show_full_call_stack = true

  return self
end

--- Disable full call stack display.
-- @treturn table self
function pimp:disableFullCallStack()
  config.pimp.show_full_call_stack = false

  return self
end

--- Set the maximum number of table elements to display.
-- Like maxArrayLength in nodejs, 0 - unlimited.
-- @tparam number n Maximum elements count
-- @treturn table self
function pimp:setMaxElements(n)
  config.pretty_print.max_elements = tonumber(n) or 0

  return self
end

--- Set the maximum displayed string length in bytes.
-- Like maxStringLength in nodejs, 0 - unlimited.
-- @tparam number n Maximum string length in bytes
-- @treturn table self
function pimp:setMaxStringLength(n)
  config.string_format.max_length = tonumber(n) or 0

  return self
end

--- Pretty-print a table ignoring the output config.
-- @tparam table t Table to pretty-print
-- @treturn string Pretty-printed representation
function pimp.pp(t)
  prettyPrint:setShowType(false)
  prettyPrint:setShowTableAddr(false)
  return prettyPrint(t)
end

--- Pretty-print a table without color and ignoring the output config.
-- @tparam table t Table to pretty-print
-- @treturn string Pretty-printed representation without color
function pimp.ppnc(t)
  local useColor = config.color.use_color
  prettyPrint:setShowType(false)
  prettyPrint:setShowTableAddr(false)
  color.colorise(false)
  local data = prettyPrint(t)
  color.colorise(useColor)
  return data
end

--- Enable local variable name lookup by value.
-- Experimental: a match by value does not guarantee the right name.
-- @treturn table self
function pimp:enableFindLocalName()
  config.pimp.find_local_name = true

  return self
end

--- Disable local variable name lookup by value.
-- @treturn table self
function pimp:disableFindLocalName()
  config.pimp.find_local_name = false

  return self
end

--- Enable argument name resolution from the call-site source line.
-- p(foo) -> foo = 42, works with expressions too: p(foo + 1) -> foo + 1 = 43.
-- Requires the source file to be readable at runtime.
-- @treturn table self
function pimp:enableFindNameFromSource()
  config.pimp.find_name_from_source = true

  return self
end

--- Disable argument name resolution from the call-site source line.
-- @treturn table self
function pimp:disableFindNameFromSource()
  config.pimp.find_name_from_source = false

  return self
end

--- Enable ladder-style call stack rendering.
-- @treturn table self
function pimp:enableCallStackLadder()
  config.pimp.show_call_stack_ladder = true

  return self
end

--- Disable ladder-style call stack rendering.
-- @treturn table self
function pimp:disableCallStackLadder()
  config.pimp.show_call_stack_ladder = false

  return self
end

--- Enable decimal to hexadecimal conversion for numbers.
-- @treturn table self
function pimp:decimalToHexadecimal()
  config.pimp.decimal_to_hexadecimal = true

  return self
end

-- The metatable makes pimp callable as a function
setmetatable(pimp, { __call = pimp.debug })

return pimp
