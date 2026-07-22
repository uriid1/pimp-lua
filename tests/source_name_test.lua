-- Tests of the argument name resolution from the call-site source line
-- Run from the repo root: lua tests/source_name_test.lua
local p = require('pimp.init')

p:disableColor()

local outfile = os.tmpname()
local failed = 0
local passed = 0

-- Capture of the p() output into a file
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
      print('~~~ output ~~~\n'..out..'~~~~~~~~~~~~~')
    end
  end
end

local function contains(str, sub)
  return str:find(sub, 1, true) ~= nil
end

local foo = 42
local bar = 'hi'
local out

--
-- The mode is off by default
--
out = capture(function()
  p(foo)
end)
ok(not contains(out, 'foo = '), 'off by default', out)

p:enableFindNameFromSource()

--
-- Plain local variable
--
out = capture(function()
  p(foo)
end)
ok(contains(out, 'foo = 42'), 'local variable name', out)

--
-- Expression
--
out = capture(function()
  p(foo + 1)
end)
ok(contains(out, 'foo + 1 = 43'), 'expression as name', out)

--
-- Nested function call
--
out = capture(function()
  p(math.floor(foo / 2))
end)
ok(contains(out, 'math.floor(foo / 2) = 21'), 'nested call as name', out)

--
-- Multiple arguments
--
out = capture(function()
  p(foo, bar)
end)
ok(contains(out, 'foo = 42') and contains(out, 'bar = "hi"'), 'two arguments', out)

--
-- Literals get no name label
--
out = capture(function()
  p(42)
end)
ok(not contains(out, ' = '), 'number literal has no name', out)

out = capture(function()
  p('a,b', foo)
end)
ok(contains(out, 'foo = 42') and not contains(out, "'a,b' ="),
  'string literal with comma inside', out)

out = capture(function()
  p(true, nil)
end)
ok(not contains(out, ' = '), 'boolean and nil literals have no name', out)

--
-- Table: name label + pretty-print
--
local t = { x = 1 }
out = capture(function()
  p(t)
end)
ok(contains(out, 't = {'), 'table name', out)

--
-- One expression produced several values - names are not applied
--
local function multiValue()
  return 1, 2
end

out = capture(function()
  p(multiValue())
end)
ok(not contains(out, ' = '), 'multi-value call: names discarded', out)

--
-- Two calls on one line - ambiguous, no names and no errors
--
out = capture(function()
  p(foo); p(bar)
end)
ok(not contains(out, 'foo = ') and not contains(out, 'bar = '),
  'two calls on one line: ambiguous', out)

--
-- Multiline call - no names and no errors
--
out = capture(function()
  p(
    foo
  )
end)
ok(contains(out, '42') and not contains(out, 'foo = '), 'multiline call: no name', out)

--
-- An alias different from p
--
local dbg = p
out = capture(function()
  dbg(foo)
end)
ok(contains(out, 'foo = 42'), 'custom alias name', out)

--
-- p.pp / p:disable on the same line do not count as a call
--
out = capture(function()
  p(bar); local _ = p.pp
end)
ok(contains(out, 'bar = "hi"'), 'p.field on same line is not a call', out)

--
-- Disabling the mode restores the old behavior
--
p:disableFindNameFromSource()
out = capture(function()
  p(foo)
end)
ok(not contains(out, 'foo = '), 'disable restores old behavior', out)

os.remove(outfile)

print(('---\n%d passed, %d failed'):format(passed, failed))
os.exit(failed == 0 and 0 or 1)
