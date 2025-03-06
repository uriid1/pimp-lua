-- Объект прототип number типа
local color = require('pimp.color')
local config = require('pimp.config')

local Number = {}
Number.__index = Number

function Number:new(varname, value)
  local obj = {}
  obj.type = 'number'
  obj.varname = varname
  obj.value = value
  obj.showType = true
  obj.colorise = true
  obj.color = color.scheme.Number

  setmetatable(obj, self)
  return obj
end

function Number:compile()
  local data = ''

  if self.varname then
    data = data..tostring(self.varname)..' = '
  end

  if config.pimp.decimal_to_hexadecimal then
    data = data..color(self.color, string.format('0x%X', self.value))
  else
    data = data..color(self.color, self.value)
  end

  if self.showType then
    data = data..': ['..self.type..']'
  end

  return data
end

function Number:setShowType(val)
  self.showType = val and true or false

  return self
end

setmetatable(Number, { __call = Number.new })

return Number
