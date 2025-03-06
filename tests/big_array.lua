local p = require('pimp')
:enableType()
:enableTableAddr()
:enableVisibility()


local arr = {}
for i = 3000, 90000 do
  arr[i] = 0
end

p(arr)
