--- Prototype object of an unknown type.
local color = require('pimp.color')

local Unknown = {}
Unknown.__index = Unknown

--- Wrapper constructor for a value of an unknown type.
-- @tparam ?string varname Variable name
-- @treturn table obj
function Unknown:new(varname)
  local obj = {}
  obj.type = 'unknown'
  obj.value = 'unknown'
  obj.varname = varname
  obj.showType = true
  obj.color = color.scheme.Unknown

  setmetatable(obj, self)
  return obj
end

--- Build a string representation of the value.
-- @treturn string data
function Unknown:compile()
  local data = ''

  if self.varname then
    data = data .. tostring(self.varname) .. ' = '
  end

  data = data .. color(self.color, self.value)

  return data
end

--- Set the type label display.
-- @tparam boolean val Enable or disable
-- @treturn table self
function Unknown:setShowType(val)
  self.showType = val and true or false

  return self
end

setmetatable(Unknown, { __call = Unknown.new })

return Unknown
