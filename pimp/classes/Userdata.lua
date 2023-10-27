local color = require('pimp.color')

local Userdata = {}
Userdata.__index = Userdata

function Userdata:new(varname, value)
  local obj = {}
  obj.type = 'userdata'
  obj.varname = varname
  obj.value = value
  obj.colorise = true
  obj.color = color.scheme.Userdata

  setmetatable(obj, self)
  return obj
end

function Userdata:compile()
  local data = ''

  if self.varname then
    data = data..tostring(self.varname)..' = '
  end

  local value = tostring(self.value)
  data = data..'<'..color(self.color, value)..'>'
  data = data..': ['..self.type..']'

  return data
end

setmetatable(Userdata, { __call = Userdata.new })

return Userdata
