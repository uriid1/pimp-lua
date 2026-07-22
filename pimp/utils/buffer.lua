--- String building buffer.
--
-- On LuaJIT 2.1+ / Tarantool >= 2.10 string.buffer (FFI buffer) is used,
-- on other versions - an array of chunks joined by table.concat.
-- Both variants give O(n) instead of O(n^2) of naive concatenation.
local hasStringBuffer, stringBuffer = pcall(require, 'string.buffer')

if hasStringBuffer then
  return function()
    return stringBuffer.new()
  end
end

local Buffer = {}
Buffer.__index = Buffer

--- Append chunks to the buffer.
-- @tparam string ... String chunks
-- @treturn table self
function Buffer:put(...)
  local items = self.items
  local n = self.n

  for i = 1, select('#', ...) do
    n = n + 1
    items[n] = select(i, ...)
  end

  self.n = n
  return self
end

--- Join the buffer content into a string.
-- @treturn string result
function Buffer:tostring()
  return table.concat(self.items)
end

return function()
  return setmetatable({ items = {}, n = 0 }, Buffer)
end
