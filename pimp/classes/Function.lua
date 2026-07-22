--- Prototype object of the function type.
local color = require('pimp.color')

local Function = {}
Function.__index = Function

--- Wrapper constructor for a function value.
-- @tparam ?string varname Variable name
-- @tparam function value Value to wrap
-- @treturn table obj
function Function:new(varname, value)
  local obj = {}
  obj.type = 'function'
  obj.varname = varname
  obj.value = value
  obj.showType = true
  obj.color = color.scheme.Function

  setmetatable(obj, self)
  return obj
end

--- Build a string representation of the value.
-- @treturn string data
function Function:compile()
  local data = ''

  if self.varname then
    data = data .. tostring(self.varname) .. ' = '
  end

  data = data .. '<' .. color(self.color, self.value) .. '>'

  return data
end

--- Set the type label display.
-- @tparam boolean val Enable or disable
-- @treturn table self
function Function:setShowType(val)
  self.showType = val and true or false

  return self
end

setmetatable(Function, { __call = Function.new })

return Function
