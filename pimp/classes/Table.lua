--- Объект прототип table типа
--
local color = require('pimp.color')

local Table = {}
Table.__index = Table

function Table:new(varname, value)
  local obj = {}
  obj.type = 'table'
  obj.varname = varname
  obj.value = value
  obj.show_table_addr = false
  obj.showType = true
  obj.colorise = true
  obj.color = color.scheme.Table

  setmetatable(obj, self)
  return obj
end

function Table:compile()
  local data = ''

  if self.varname then
    if self.show_table_addr then
      local adress = color(color.scheme.debugAddress, tostring(self.value))
      data = data
        .. color(color.scheme.tablePrefix, tostring(self.varname))
        .. ': <'..adress..'> = '
    else
      data = data..color(color.scheme.tablePrefix, tostring(self.varname))..' = '
    end
  end

  return data
end

function Table:setShowType(val)
  self.showType = val and true or false

  return self
end

function Table:setShowTableAddr(val)
  self.show_table_addr = val and true or false

  return self
end

setmetatable(Table, { __call = Table.new })

return Table
