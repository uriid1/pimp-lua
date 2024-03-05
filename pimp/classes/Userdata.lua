local color = require('pimp.color')

local Userdata = {}
Userdata.__index = Userdata

function Userdata:new(varname, value)
  local obj = {}
  obj.type = 'userdata'
  obj.varname = varname
  obj.value = value
  obj.showType = true
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

  if self.showType then
    data = data..': ['..self.type..']'
  end

  return data
end

function Userdata:setShowType(val)
  self.showType = val and true or false

  return self
end

setmetatable(Userdata, { __call = Userdata.new })

return Userdata
