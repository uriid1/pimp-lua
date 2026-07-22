local p = require('pimp.init')

p:enableFindLocalName()

local x = 123
p(x)

local function foo()
  local y = 456
  (function ()
    p(y)
  end)()
end

foo()

local a = 'Hello'
local function fn()
  return function(b)
    p(a, b)
  end
end

fn()('World')
