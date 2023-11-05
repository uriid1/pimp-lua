local color = require('pimp.color')
local stringFormat = require('pimp.string-format')

local String = {}
String.__index = String

function String:new(varname, value)
  local obj = {}
  obj.type = 'string'
  obj.varname = varname
  obj.value = stringFormat(value)
  obj.length = #value
  obj.showType = true
  obj.colorise = true
  obj.color = color.scheme.String

  setmetatable(obj, self)
  return obj
end

function String:compile()
  local data = ''

  if self.varname then
    data = data..tostring(self.varname)..' = '
  end

  data = data..'\''..color(self.color, self.value)..'\''

  if self.showType then
    data = data..': ['..self.length..' byte]'
  end

  return data
end

function String:setShowType(val)
  self.showType = val and true or false

  return self
end

setmetatable(String, { __call = String.new })

return String
