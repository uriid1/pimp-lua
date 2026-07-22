--- Prototype object of the userdata type.
local color = require('pimp.color')

local Userdata = {}
Userdata.__index = Userdata

--- Wrapper constructor for a userdata value.
-- @tparam ?string varname Variable name
-- @tparam userdata value Value to wrap
-- @treturn table obj
function Userdata:new(varname, value)
  local obj = {}
  obj.type = 'userdata'
  obj.varname = varname
  obj.value = value
  obj.showType = true
  obj.color = color.scheme.Userdata

  setmetatable(obj, self)
  return obj
end

--- Build a string representation of the value.
-- @treturn string data
function Userdata:compile()
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
function Userdata:setShowType(val)
  self.showType = val and true or false

  return self
end

setmetatable(Userdata, { __call = Userdata.new })

return Userdata
