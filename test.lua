local p = require 'pimp.init'
-- p:disable() -- Disable debug output

local function sum(a, b)
  local result = a + b
  return result
end

local function mv(a, b, c)
  return a, b, c, true, 'foobar'
end

p(sum(7, 5))
p(mv(1, 2, 3))
p('Hello, World!')
p(10000)
p()
p(true)

p(coroutine.create(sum))
local co = coroutine.create(sum)
p(co)

p(function() end)
-- For tarantool
if box then p(box.NULL) end

p:setPrefix('Test| ')
p(7, 'hello', {})
p('foo', co, sum(4, 12))

p:setPrefix('Disable colors| ')
p.setUseColors(false)
p('String without colors')
p.setUseColors(true)
p:setPrefix('p| ')

-- PP array
p({1, 2, 3})

local obj = {
  message = {
    chat = {
      title = 'Кто съел мороженое?',
    }
  },

  ['array'] = {
    'apple', 'banana', 'orange'
  },

  boolean = true,
  string = 'Hello, world!',
  func = function() end,
  thread = coroutine.create(function() end),
  empty_table = {},
  NULL = box and box.NULL or ':)'
}

obj.recursive = obj

p(obj)
