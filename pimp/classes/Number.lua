local color = require('pimp.color')

local Number = {}
Number.__index = Number

function Number:new(varname, value)
  local obj = {}
  obj.type = 'number'
  obj.varname = varname
  obj.value = value
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

  data = data..color(self.color, self.value)
  data = data..': ['..self.type..']'

  return data
end

setmetatable(Number, { __call = Number.new })

return Number
