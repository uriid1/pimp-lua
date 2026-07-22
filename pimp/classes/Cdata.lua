--- Prototype object of the cdata (LuaJIT/Tarantool) type.
local color = require('pimp.color')

local Cdata = {}
Cdata.__index = Cdata

--- Wrapper constructor for a cdata value.
-- @tparam ?string varname Variable name
-- @tparam cdata value Value to wrap
-- @treturn table obj
function Cdata:new(varname, value)
  local obj = {}
  obj.type = 'cdata'
  obj.varname = varname
  obj.value = value
  obj.showType = true

  -- cdata NULL is highlighted in red: the value is truthy yet equals nil
  if value and value == nil then
    obj.color = color.red
  else
    obj.color = color.scheme.Cdata
  end

  setmetatable(obj, self)
  return obj
end

--- Build a string representation of the value.
-- @treturn string data
function Cdata:compile()
  local data = ''

  if self.varname then
    data = data .. tostring(self.varname) .. ' = '
  end

  data = data .. '<' .. color(self.color, tostring(self.value)) .. '>'

  if self.showType then
    data = data .. ': [' .. self.type .. ']'
  end

  return data
end

--- Set the type label display.
-- @tparam boolean val Enable or disable
-- @treturn table self
function Cdata:setShowType(val)
  self.showType = val and true or false

  return self
end

setmetatable(Cdata, { __call = Cdata.new })

return Cdata
