local p = require 'pimp.init'

local function sum(a, b)
  local result = a + b
  return result
end

-- p| test.lua:9: sum(7, 5): 12: [number]
p(sum(7, 5))
-- p| test.lua:11: 'Hello, World!': [string length 13]
p('Hello, World!')
-- p| test.lua:13: 10000: [number]
p(10000)
-- p| test.lua:15
p()
-- p| test.lua:17: true: [boolean]
p(true)
-- p| test.lua:19: coroutine.create(sum): thread: 0x41380a80
p(coroutine.create(sum))
-- p| test.lua:22: thread: 0x41ef0fa8
local co = coroutine.create(sum)
p(co)
-- p| test.lua:22: thread: 0x41ef0fa8
p(function() end)
-- p| test.lua:26: {1, 2, 3}
p({1, 2, 3})
-- p| test.lua:28: 7: [number], 'hello': [string length 5], table: 0x40716d10
p(7, 'hello', {})
-- p| test.lua:30: 'foo': [string length 3], thread: 0x41ef0fa8, 16: [number]
p('foo', co, sum(4, 12))

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
}

obj.recursive = obj

p(obj)

local function mv(a, b, c)
  return a, b, c, true, 'foobar'
end

p(mv(1, 2, 3))

-- For tarantool
if box then
  p(box.NULL)
end