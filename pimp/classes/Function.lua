-- Объект прототип фукнции
local color = require('pimp.color')

local Function = {}
Function.__index = Function

function Function:new(varname, value)
  local obj = {}
  obj.type = 'function'
  obj.varname = varname
  obj.value = value
  obj.showType = true
  obj.colorise = true
  obj.color = color.scheme.Function

  setmetatable(obj, self)
  return obj
end

function Function:compile()
  local data = ''

  if self.varname then
    data = data..tostring(self.varname)..' = '
  end

  data = data..'<'..color(self.color, self.value)..'>'

  return data
end

function Function:setShowType(val)
  self.showType = val and true or false

  return self
end

setmetatable(Function, { __call = Function.new })

return Function
