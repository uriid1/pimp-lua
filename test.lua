local p = require('pimp.init')
-- p:disable() -- Disable debug output
:enableType() -- Enable show type
:enableTableAddr() -- Enable show table address
:enableVisibility() -- local / global

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

local str = "foo %s bar"


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
  local NAME = 'uriid1'
  p(NAME)
  p(a, b, c)

  if box then
    local cdata = box.NULL
    p(cdata)
  end

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
  p:disableVisibility()
  p(t1, t2, t3)
  p:enableVisibility()
end

tt(t1, t2, {})

local t1 = {}
setmetatable(t1, {
  __add = function() end,
  __sub = function() end,
  __mul = function() end,
})

local t2 = {1, 2, 3}
setmetatable(t2, { __tostring = function() end })

p(getmetatable(t1))

--
function test_1(a, ...) p(); return a, ... end
function test_2(b, ...) p(); return b, ... end
function test_3(c, ...) p(); return c, ... end

test_1('foo', p(test_1), p(test_2, test_2), 'baz', p(test_3))

--
-- Inspect Tables
--
local arrTest = {
  [-99] = 'Array?'
}
p(arrTest)

local strArr = {
  ["1"] = 1,
  ["2"] = 2,
  ["3"] = 3,
}
p(strArr)

local table_name = {
  message = {
    chat = {
      title = 'Кто съел мороженое?',
    }
  },

  ['array'] = {
    "apple.", 'banana', 'orange', 'green'
  },

  inf = 1/0,
  nan = 0/0,
  boolean = true,
  string = '\tHello,\r\nworld!\r\n $(.-)^',
  func = function() end,
  thread = coroutine.create(function() end),
  empty_table = {},
  NULL = box and box.NULL or ':)'
}
table_name.recursive = table_name

p(table_name)

--
-- Inspect Tuple
--
if box and box.tuple then
  local tuple = box.tuple.new {'foo', 'bar', 'baz'}
  p(tuple)
end

--
-- Log
--
p.log.ignore = {'info', 'warn'}
p.log.trace(('Trace %s'):format 'message')
p.log.debug('Debug message')
p.log.info('Info message')
p.log.warn('Warn message')
p.log.error('Error message')
p.log.fatal('Fatal message')
