local color = require('pimp.color')

local Boolean = {}
Boolean.__index = Boolean

function Boolean:new(varname, value)
  local obj = {}
  obj.type = 'boolean'
  obj.varname = varname
  obj.value = value
  obj.showType = true
  obj.colorise = true
  obj.color = color.scheme.Boolean

  setmetatable(obj, self)
  return obj
end

function Boolean:compile()
  local data = ''

  if self.varname then
    data = data..tostring(self.varname)..' = '
  end

  data = data..color(self.color, self.value)

  if self.showType then
    data = data..': ['..self.type..']'
  end

  return data
end

function Boolean:setShowType(val)
  self.showType = val and true or false

  return self
end

setmetatable(Boolean, { __call = Boolean.new })

return Boolean
