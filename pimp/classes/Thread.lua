--- Prototype object of the thread type.
local color = require('pimp.color')

local Thread = {}
Thread.__index = Thread

--- Wrapper constructor for a thread value.
-- @tparam ?string varname Variable name
-- @tparam thread value Value to wrap
-- @treturn table obj
function Thread:new(varname, value)
  local obj = {}
  obj.type = 'thread'
  obj.varname = varname
  obj.value = value
  obj.showType = true
  obj.color = color.scheme.Thread

  setmetatable(obj, self)
  return obj
end

--- Build a string representation of the value.
-- @treturn string data
function Thread:compile()
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
function Thread:setShowType(val)
  self.showType = val and true or false

  return self
end

setmetatable(Thread, { __call = Thread.new })

return Thread
