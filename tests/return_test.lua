local p = require('pimp.init')
-- p:disable() -- Disable debug output
:enableType() -- Enable show type
:enableTableAddr() -- Enable show table address
:enableVisibility() -- local / global / ..

local function foo()
  return 'bar'
end

if true then
  local result = foo()
  p(result)
  return p(result)
end
