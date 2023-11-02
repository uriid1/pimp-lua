local p = require 'pimp.init'
-- p:disable() -- Disable debug output

--
-- Inspect Variables
--
p('Pimp Module!')
p(true, false, nil)
p(function() end)
p(io.stderr)
p(10000, math.pi)
p(0/0, -1/0, 1/0)

local test = function () end
p(function() end, test)

local co = coroutine.create(function() end)
p(co)

if box then
  p(box.NULL)
end


--
-- Change prefix test
--
p:setPrefix({ prefix = 'INFO', sep = '|-> ' })
p('Wow! It\'s new prefix!')
p:resetPrefix()


--
-- Disable color test
--
p:disableColor()
p('String without colors')
p:enableColor()


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
  return a, b, c
end
p(mv(1, 2, 3))

local _ = (function(...)
  p(...)
  return true
end)(4, 5, 6)

local function infunc(a, b)
  p(a, b)
  return a + b
end
p(infunc(10, 5))

local function func(arg1, ...)
  return p(arg1, ...)
end
func(1, '2', {})

local function funcVararg(...)
  p()
end
funcVararg()

local function tt(t1, t2, t3)
  p(t1, t2, t3)
end

local t1 = {}
setmetatable(t1, { __add = function() end })

local t2 = {1, 2, 3}
setmetatable(t2, { __tostring = function() end })

tt(t1, t2, {})

--
function test_1(a, ...) p(); return a, ... end
function test_2(b, ...) p(); return b, ... end
function test_3(c, ...) p(); return c, ... end

test_1('foo', p(test_1), p(test_2, test_2), 'baz', p(test_3))

--
-- Inspect Tables
--
p({ [-99] = 'Array?' })

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
