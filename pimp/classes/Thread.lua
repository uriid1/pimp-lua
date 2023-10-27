local color = require('pimp.color')

local Thread = {}
Thread.__index = Thread

function Thread:new(varname, value)
  local obj = {}
  obj.type = 'thread'
  obj.varname = varname
  obj.value = value
  obj.colorise = true
  obj.color = color.scheme.Thread

  setmetatable(obj, self)
  return obj
end

function Thread:compile()
  local data = ''

  if self.varname then
    data = data..tostring(self.varname)..' = '
  end

  data = data..'<'..color(self.color, self.value)..'>'

  return data
end

setmetatable(Thread, { __call = Thread.new })

return Thread
