local color = require('pimp.color')

local Cdata = {}
Cdata.__index = Cdata

function Cdata:new(varname, value)
  local obj = {}
  obj.type = 'cdata'
  obj.varname = varname
  obj.value = value
  obj.colorise = true

  -- Detect CDATA NULL
  if value and value == nil then
    obj.color = color.red
  else
    obj.color = color.scheme.Cdata
  end

  setmetatable(obj, self)
  return obj
end

function Cdata:compile()
  local data = ''

  if self.varname then
    data = data..tostring(self.varname)..' = '
  end

  local value = tostring(self.value)
  data = data..'<'..color(self.color, value)..'>'
  data = data..': ['..self.type..']'

  return data
end

setmetatable(Cdata, { __call = Cdata.new })

return Cdata
