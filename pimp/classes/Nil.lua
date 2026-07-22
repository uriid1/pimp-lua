--- Prototype object of the nil type.
local color = require('pimp.color')

local Nil = {}
Nil.__index = Nil

--- Wrapper constructor for a nil value.
-- @tparam ?string varname Variable name
-- @treturn table obj
function Nil:new(varname)
  local obj = {}
  obj.type = 'nil'
  obj.value = 'nil'
  obj.varname = varname
  obj.showType = true
  obj.color = color.scheme.Nil

  setmetatable(obj, self)
  return obj
end

--- Build a string representation of the value.
-- @treturn string data
function Nil:compile()
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
function Nil:setShowType(val)
  self.showType = val and true or false

  return self
end

setmetatable(Nil, { __call = Nil.new })

return Nil
