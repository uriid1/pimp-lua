-- Luacheck configuration.
-- std max: the library supports Lua 5.1-5.4 and LuaJIT, so version-specific
-- globals (getfenv, _ENV) are legal in guarded branches.
std = 'max'
max_line_length = 130

-- Acceptable warnings (see the style guide):
-- 411-413 - redefining a local / an argument / a loop variable
-- 421-423 - shadowing a local
-- 431-433 - shadowing an upvalue
-- 581 - not (x == y)
ignore = {
  '411', '412', '413',
  '421', '422', '423',
  '431', '432', '433',
  '581',
}

files['tests'] = {
  -- box - the Tarantool global, tests probe it to cover box.NULL
  read_globals = { 'box' },
  -- 211 - unused variables are intentional in demo tests
  ignore = { '211' },
}
