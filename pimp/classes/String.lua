--- Prototype object of the string type.
local color = require('pimp.color')
local stringFormat = require('pimp.string_format')

local String = {}
String.__index = String

--- Wrapper constructor for a string value.
-- @tparam ?string varname Variable name
-- @tparam string value Value to wrap
-- @treturn table obj
function String:new(varname, value)
  local obj = {}
  obj.type = 'string'
  obj.varname = varname
  obj.value, obj.truncated = stringFormat(value)
  -- length - real length of the source string, before truncation
  obj.length = #value
  obj.showType = true
  obj.color = color.scheme.String

  setmetatable(obj, self)
  return obj
end

--- Build a string representation of the value.
-- @treturn string data
function String:compile()
  local data = ''

  if self.varname then
    data = data .. tostring(self.varname) .. ' = '
  end

  data = data .. '"' .. self.value .. '"'

  if self.truncated and self.truncated > 0 then
    data = data .. color(color.scheme.truncated, (' ... (%d more bytes)'):format(self.truncated))
  end

  if self.showType then
    data = data .. ': [' .. color(color.scheme.Number, self.length) .. ' byte]'
  end

  return data
end

--- Set the type label display.
-- @tparam boolean val Enable or disable
-- @treturn table self
function String:setShowType(val)
  self.showType = val and true or false

  return self
end

setmetatable(String, { __call = String.new })

return String
