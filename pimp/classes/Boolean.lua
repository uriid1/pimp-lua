--- Prototype object of the boolean type.
local color = require('pimp.color')

local Boolean = {}
Boolean.__index = Boolean

--- Wrapper constructor for a boolean value.
-- @tparam ?string varname Variable name
-- @tparam boolean value Value to wrap
-- @treturn table obj
function Boolean:new(varname, value)
  local obj = {}
  obj.type = 'boolean'
  obj.varname = varname
  obj.value = value
  obj.showType = true
  obj.color = color.scheme.Boolean

  setmetatable(obj, self)
  return obj
end

--- Build a string representation of the value.
-- @treturn string data
function Boolean:compile()
  local data = ''

  if self.varname then
    data = data .. tostring(self.varname) .. ' = '
  end

  data = data .. color(self.color, self.value)

  if self.showType then
    data = data .. ': [' .. self.type .. ']'
  end

  return data
end

--- Set the type label display.
-- @tparam boolean val Enable or disable
-- @treturn table self
function Boolean:setShowType(val)
  self.showType = val and true or false

  return self
end

setmetatable(Boolean, { __call = Boolean.new })

return Boolean
