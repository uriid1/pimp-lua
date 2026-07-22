-- Tests of the output limits (nodejs style) and string formatting
-- Run from the repo root: lua tests/limit_test.lua
local p = require('pimp.init')
local config = require('pimp.config')

p:disableColor()

local outfile = os.tmpname()
local failed = 0
local passed = 0

local function capture(fn)
  io.output(outfile)
  fn()
  io.output(io.stdout)

  local fd = assert(io.open(outfile, 'r'))
  local data = fd:read('*a')
  fd:close()

  return data
end

local function ok(cond, name, out)
  if cond then
    passed = passed + 1
    print('OK   '..name)
  else
    failed = failed + 1
    print('FAIL '..name)
    if out then
      print('--- output ---\n'..out..'--------------')
    end
  end
end

local function contains(str, sub)
  return str:find(sub, 1, true) ~= nil
end

local out

--
-- Long string truncation
--
p:setMaxStringLength(10)
out = capture(function()
  p('abcdefghijklmnop')
end)
ok(contains(out, 'abcdefghij') and contains(out, '(6 more bytes)')
  and not contains(out, 'klmnop'), 'string truncated', out)

-- The real string length is shown, before truncation
p:enableType()
out = capture(function()
  p('abcdefghijklmnop')
end)
ok(contains(out, '[16 byte]'), 'real byte length shown', out)
p:disableType()

-- 0 - unlimited
p:setMaxStringLength(0)
out = capture(function()
  p('abcdefghijklmnop')
end)
ok(contains(out, 'abcdefghijklmnop') and not contains(out, 'more bytes'),
  'unlimited string when 0', out)

p:setMaxStringLength(10000)

--
-- Table elements limit
--
p:setMaxElements(3)
local arr = { 10, 20, 30, 40, 50 }
out = capture(function()
  p(arr)
end)
ok(contains(out, '... 2 more elements'), 'array truncated', out)

-- Exactly maxElements entries are shown
local shown = 0
for _ in out:gmatch('%[%d+%] = ') do
  shown = shown + 1
end
ok(shown == 3, 'exactly maxElements shown', out)

-- 0 - unlimited
p:setMaxElements(0)
out = capture(function()
  p(arr)
end)
ok(not contains(out, 'more elements'), 'unlimited elements when 0', out)

-- Big array
p:setMaxElements(100)
local bigArr = {}
for i = 1, 1000 do
  bigArr[i] = i
end
out = capture(function()
  p(bigArr)
end)
ok(contains(out, '... 900 more elements'), 'big array: 900 more', out)

-- Nested tables are limited independently
p:setMaxElements(2)
out = capture(function()
  p({ nested = { 1, 2, 3, 4 } })
end)
ok(contains(out, '... 2 more elements'), 'nested table truncated', out)
p:setMaxElements(100)

--
-- String formatting regression after the buffer rewrite
--
out = capture(function()
  p('line1\nline2\ttab')
end)
ok(contains(out, '\\n') and contains(out, '\\t'), 'escape controls still work', out)

config.string_format.escape_controls = false
out = capture(function()
  p('hello world')
end)
ok(contains(out, 'hello world'), 'escape_controls=false keeps content', out)
config.string_format.escape_controls = true

out = capture(function()
  p('%w+ pattern $')
end)
ok(contains(out, '%w+ pattern $'), 'pattern chars survive', out)

--
-- Cycles and repeated references are not broken by the buffer
--
local cyc = {}
cyc.self = cyc
out = capture(function()
  p(cyc)
end)
ok(contains(out, 'cycle'), 'cycle still detected', out)

os.remove(outfile)

print(('---\n%d passed, %d failed'):format(passed, failed))
os.exit(failed == 0 and 0 or 1)
