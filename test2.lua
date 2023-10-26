local p = require '.pimp.init'

local function find_name_by_addr(addr)
  for i = 1, math.huge do
    local name, value = debug.getlocal(3, i)
    if not name and not value then
      break
    end

    if value == addr then
      return name
    end
  end

  return nil
end

-- local function p(func)
--   print(find_name_by_addr(func))
-- end

local func_1 = function(...) return ... end
local func_2 = function() end

local function foobar(...)

end

func_1(p('founc_o'), p(func_1), p('bar'), p(func_2))


function test_1(a, ...) p(); return a, ... end
function test_2(b, ...) p(); return b, ... end
function test_3(c, ...) p(); return c, ... end

test_1('foo', p(test_1), 'bar', p(test_2), 'baz', p(test_3))
