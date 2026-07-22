local p = require('pimp.init')

p:setMaxElements(15)

local t = {}
for i = 1, 50 do
  t[i] = i
end

p(t)
