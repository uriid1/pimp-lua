-- Модуль для распечатки таблицы
--
local color = require 'modules.color'
local tocolor = color.tocolor

local M = {
  colorize = true,
  debug = false,
}

function M:wrap(obj, indent, seen)
  indent = indent or 0
  seen = seen or {}

  if obj == nil then
    return tocolor(obj, 'nil')
  elseif type(obj) == 'table' then
    -- Check if we've already seen this table
    if seen[obj] then
      local table_adrr = tostring(obj):match('table: (.+)')
      return tocolor('<cycle: '..tocolor(table_adrr, 'address')..tocolor('>', 'cycle'), 'cycle')
    end
    seen[obj] = true

    -- Detect empty table
    local is_mpty = not next(obj)
    if is_mpty then
      return tocolor('{}', 'table')
    end

    local str = tocolor('{\n', 'table')
    for key, val in pairs(obj) do
      local _type = type(val)

      -- Detect array
      local is_arr = tonumber(key)

      -- Detect table
      local val_is_table = _type == 'table'

      local fstr -- ident|value| debug| =
      if is_arr then
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
          string.rep(" ", indent+2),
          tocolor(key, 'field'),
          tocolor(table_adrr, 'address')
        )
      else
        str = str .. fstr:format(
          string.rep(' ', indent+2),
          tocolor(key, 'field')
        )
      end

      local success, result = pcall(function()
        return self:wrap(val, indent+2, seen)
      end)

      if not success then
        result = tocolor('<error: '..tostring(result)..'>', 'error')
      end

      str = str..result..',\n'
    end

    str = str..string.rep(' ', indent)..tocolor('}', 'table')
    return str
  else
    return tocolor(obj, type(obj))
  end
end

function M.pp(obj)
  print(M:wrap(obj))
end

setmetatable(M, { __call = M.pp })

return M
