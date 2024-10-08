-- Объект прототип неопределенного типа
local color = require('pimp.color')

local Unknown = {}
Unknown.__index = Unknown

function Unknown:new(varname)
  local obj = {}
  obj.type = 'unknown'
  obj.value = 'unknown'
  obj.varname = varname
  obj.showType = true
  obj.colorise = true
  obj.color = color.scheme.Unknown

  setmetatable(obj, self)
  return obj
end

function Unknown:compile()
  local data = ''

  if self.varname then
    data = data..tostring(self.varname)..' = '
  end

  data = data..color(self.color, self.value)

  return data
end

function Unknown:setShowType(val)
  self.showType = val and true or false

  return self
end

setmetatable(Unknown, { __call = Unknown.new })

return Unknown
