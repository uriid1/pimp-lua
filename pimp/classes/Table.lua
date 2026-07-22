--- Prototype object of the table type.
local color = require('pimp.color')

local Table = {}
Table.__index = Table

--- Wrapper constructor for a table value.
-- @tparam ?string varname Variable name
-- @tparam table value Value to wrap
-- @treturn table obj
function Table:new(varname, value)
  local obj = {}
  obj.type = 'table'
  obj.varname = varname
  obj.value = value
  obj.showTableAddr = false
  obj.showType = true
  obj.color = color.scheme.Table

  setmetatable(obj, self)
  return obj
end

--- Build the table prefix: variable name and optionally the address.
-- The table content itself is printed by pretty_print.
-- @treturn string data
function Table:compile()
  local data = ''

  if self.varname then
    if self.showTableAddr then
      local address = color(color.scheme.debugAddress, tostring(self.value))
      data = data
        .. color(color.scheme.tablePrefix, tostring(self.varname))
        .. ': <' .. address .. '> = '
    else
      data = data .. color(color.scheme.tablePrefix, tostring(self.varname)) .. ' = '
    end
  end

  return data
end

--- Set the type label display.
-- @tparam boolean val Enable or disable
-- @treturn table self
function Table:setShowType(val)
  self.showType = val and true or false

  return self
end

--- Set the table address display.
-- @tparam boolean val Enable or disable
-- @treturn table self
function Table:setShowTableAddr(val)
  self.showTableAddr = val and true or false

  return self
end

setmetatable(Table, { __call = Table.new })

return Table
