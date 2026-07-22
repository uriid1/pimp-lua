--- Prototype object of the number type.
local color = require('pimp.color')
local config = require('pimp.config')

local Number = {}
Number.__index = Number

--- Wrapper constructor for a number value.
-- @tparam ?string varname Variable name
-- @tparam number value Value to wrap
-- @treturn table obj
function Number:new(varname, value)
  local obj = {}
  obj.type = 'number'
  obj.varname = varname
  obj.value = value
  obj.showType = true
  obj.color = color.scheme.Number

  setmetatable(obj, self)
  return obj
end

--- Build a string representation of the value.
-- @treturn string data
function Number:compile()
  local data = ''

  if self.varname then
    data = data .. tostring(self.varname) .. ' = '
  end

  -- %X is applicable only to integers in the 64-bit range:
  -- fractional, nan, inf and too large numbers are printed as is
  local value = self.value
  if config.pimp.decimal_to_hexadecimal
    and value % 1 == 0
    and value >= -2 ^ 63
    and value < 2 ^ 63
  then
    data = data .. color(self.color, string.format('0x%X', value))
  else
    data = data .. color(self.color, value)
  end

  if self.showType then
    data = data .. ': [' .. self.type .. ']'
  end

  return data
end

--- Set the type label display.
-- @tparam boolean val Enable or disable
-- @treturn table self
function Number:setShowType(val)
  self.showType = val and true or false

  return self
end

setmetatable(Number, { __call = Number.new })

return Number
