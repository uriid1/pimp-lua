local color = require('pimp.color')

local Table = {}
Table.__index = Table

function Table:new(varname, value)
  local obj = {}
  obj.type = 'table'
  obj.varname = varname
  obj.value = value
  obj.showType = true
  obj.colorise = true
  obj.color = color.scheme.Table

  setmetatable(obj, self)
  return obj
end

function Table:compile()
  local data = ''

  if self.varname then
    data = data..tostring(self.varname)..' = '
  end

  return data
end

function Table:setShowType(val)
  self.showType = val and true or false

  return self
end

setmetatable(Table, { __call = Table.new })

return Table
