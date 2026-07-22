--- Known metamethods enum.

--- Metamethod names used to highlight metatable fields.
-- @table metamethods
local metamethods = {
  __call = true,
  __concat = true,
  __tostring = true,
  __metatable = true,
  __mode = true,
  __gc = true,
  __index = true,
  __newindex = true,
  -- Arithmetic
  __add = true,
  __sub = true,
  __mul = true,
  __div = true,
  __pow = true,
  __mod = true,
  __unm = true,
  __idiv = true, -- 5.3+
  -- Comparison
  __eq = true,
  __lt = true,
  __le = true,
  -- Length and iteration
  __len = true,
  __ipairs = true,
  __pairs = true, -- 5.2+
  -- Bitwise operators (5.3+)
  __band = true,
  __bor = true,
  __bxor = true,
  __bnot = true,
  __shl = true,
  __shr = true,
  -- Tarantool
  __serialize = true,
}

return metamethods
