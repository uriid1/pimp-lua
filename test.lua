local p = require 'pimp.init'
-- p:disable() -- Disable debug output

--
-- Inspect Variables
--
p('Hello, World!')
p(10000, math.pi)
p(true, false)
p(0/0, -1/0, 1/0)
p(function() end)
p(coroutine.create(function() end))
p(io.stderr)

--
-- Change prefix test
--
p:setPrefix('Test| ')
p('Wow! It\'s new prefix!')
p:setPrefix('p| ')

--
-- Disable color test
--
p:disableColor(false)
p('String without colors')
p:enableColor(true)

--
-- Disable test
--
p:disable()
p('Hello?')
p:enable()

--
-- Inspect Functions
--
local function foo(t)
  return t, true
end

p(
  foo({
    'apple', 'banana', 'orange'
  })
)

local function mv(a, b, c)
  p('Message from local func')
  return a, b, c, true, 'foobar'
end
p(mv(1, 2, 3))

local _ = (function(...)
  p(...)
  return true
end)(1, 2, 3)

local function infunc(a, b)
  p(a, b)
  return a + b
end
p(infunc(10, 5))

local function func(arg1, ...)
  return p(arg1, ...)
end
func(1, '2', {})


--
-- Inspect Tables
--
p({1, 2, 3})

local t = {
  message = {
    chat = {
      title = 'Кто съел мороженое?',
    }
  },

  ['array'] = {
    'apple', 'banana', 'orange'
  },

  inf = 1/0,
  nan = 0/0,
  boolean = true,
  string = '\tHello,\r\nworld!\r\n',
  func = function() end,
  thread = coroutine.create(function() end),
  empty_table = {},
  NULL = box and box.NULL or ':)'
}
t.recursive = t

p(t)
