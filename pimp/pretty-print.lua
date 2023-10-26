---
-- Table Printing Module
-- @module pretty-print
local type_constructor = require 'pimp.type_constructor'
local color = require 'pimp.color'
local tocolor = color.tocolor

local M = {
  debug = false,
  tab_char = ' ',
}

local merge
function merge(t1, t2)
  for k, v in pairs(t2) do
    t1[k] = v
  end
end

--
local function isArray(t)
  if type(t) ~= 'table' then
    return false
  end

  local i = 1
  for _ in next, t do
    if t[i] == nil then
      return false, nil
    end

    i = i + 1
  end

  return true, i-1
end

--- Wrap an object for pretty printing.
-- @param obj any The object to be pretty-printed.
-- @param indent number The indentation level (optional, default is 0).
-- @param seen table A table to keep track of visited objects (optional).
-- @return string The pretty-printed string.
function M:wrap(obj, indent, seen)
  indent = indent or 0
  seen = seen or {}

  if obj == nil then
    return tocolor(obj, 'nil')
  elseif type(obj) == 'table' then
    -- Check if we've already seen this table
    if seen[obj] then
      local table_adrr = tostring(obj):match('table: (.+)')
      return tocolor('<cycle: ' .. table_adrr.. tocolor('>', 'cycle'), 'cycle')
    end
    seen[obj] = true

    if self.debug then
      merge(obj, getmetatable(obj))
    end

    -- Detect empty table
    local is_empty = not next(obj)
    if is_empty then
      return tocolor('{}', 'table')
    end

    local str = tocolor('{\n', 'table')
    for key, val in pairs(obj) do
      local _type = type(val)

      -- Detect array
      local is_array = tonumber(key)

      -- Detect table
      local val_is_table = _type == 'table'

      local fstr -- ident|value| debug| =
      if is_array then
        if self.debug and val_is_table then
          fstr = '%s[%s] %s = '
        else
          fstr = '%s[%s] = '
        end
      else
        if self.debug and val_is_table then
          fstr = '%s%s %s = '
        else
          fstr = '%s%s = '
        end
      end

      if self.debug and val_is_table then
        local table_adrr = tostring(val):match('table: (.+)')
        str = str .. fstr:format(
          string.rep(self.tab_char, indent + 2),
          tocolor(key, 'field'),
          tocolor(table_adrr, 'address')
        )
      else
        local color_type = 'field'

        if type(key) == 'number' then
          color_type = 'number'
        end

        str = str .. fstr:format(
          string.rep(self.tab_char, indent + 2),
          tocolor(key, color_type)
        )
      end

      local success, result = pcall(function()
        return self:wrap(val, indent + 2, seen)
      end)

      if not success then
        result = tocolor('<error: ' .. tostring(result) .. '>', 'error')
      end

      str = str .. result .. ',\n'
    end

    --
    local label_type = ''
    local is_arr, arr_count = isArray(obj)

    if is_arr then
      label_type = label_type .. ': [array '..arr_count..']'
    end

    str = str .. string.rep(self.tab_char, indent) .. tocolor('}', 'table')..label_type

    return str
  else
    return type_constructor(obj)
  end
end

---
-- Print a pretty representation of an object.
-- @param ... any objects to be printed.
function M:pp(...)
  local args_count = select('#', ...)
  if args_count == 0 then
    io.write(M:wrap(nil), '\n')
    io.flush()
    return
  end

  local data = {}
  for i = 1, args_count do
    local arg = select(i, ...)
    table.insert(data, M:wrap(arg))
  end

  io.write(table.concat(data, ', '), '\n')
  io.flush()
end

---
-- Set up the module to be callable as a function, invoking the 'pp' function.
setmetatable(M, { __call = M.pp })

return M