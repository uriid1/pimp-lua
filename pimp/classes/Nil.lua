-- Объект прототип nil типа
local color = require('pimp.color')

local Nil = {}
Nil.__index = Nil

function Nil:new(varname)
  local obj = {}
  obj.type = 'nil'
  obj.value = 'nil'
  obj.varname = varname
  obj.showType = true
  obj.colorise = true
  obj.color = color.scheme.Nil

  setmetatable(obj, self)
  return obj
end

function Nil:compile()
  local data = ''

  if self.varname then
    data = data..tostring(self.varname)..' = '
  end

  data = data..color(self.color, self.value)

  return data
end

function Nil:setShowType(val)
  self.showType = val and true or false

  return self
end

setmetatable(Nil, { __call = Nil.new })

return Nil
