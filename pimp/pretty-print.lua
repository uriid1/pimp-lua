---
-- Table Printing Module
-- @module pretty-print
--
local color = require 'pimp.color'
local constructor = require 'pimp.constructor'

local prettyPrint = {
  debug = false,
  tab_char = ' ',
}

--
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

--- Wrap an object for pretty printing
-- @param obj any The object to be pretty-printed
-- @param indent number The indentation level (optional, default is 0)
-- @param seen table A table to keep track of visited objects (optional)
-- @return string The pretty-printed string
function prettyPrint:wrap(obj, indent, seen)
  local objType = type(obj)
  indent = indent or 0
  seen = seen or {}

  if objType == 'nil' then
    return constructor('nil', obj):compile()
  elseif objType == 'table' then
    -- Check if we've already seen this table
    if seen[obj] then
      local address = tostring(obj)
      if address:find('table: ') then
        address = address:match('table: (.+)')
      end
      return '<'..color(color.scheme.cycleTable, 'cycle: '..address)..'>'
    end
    seen[obj] = true

    if self.debug then
      local __mt = getmetatable(obj)
      if __mt then
        merge(obj, __mt)
      end
    end

    -- Detect empty table
    local is_empty = not next(obj)
    if is_empty then
      return color(color.scheme.emtyTable, '{}')
    end

    local str = color(color.scheme.tableBrackets, '{\n')
    for key, val in pairs(obj) do
      local typeVal = type(val)

      -- Detect array
      local KeyIsArray = tonumber(key)

      -- Detect table
      local valIsTable = typeVal == 'table'

      local fstr -- ident|value| debug| =
      if KeyIsArray then
        if self.debug and valIsTable then
          fstr = '%s[%s] %s = '
        else
          fstr = '%s[%s] = '
        end
      else
        if self.debug and valIsTable then
          fstr = '%s%s %s = '
        else
          fstr = '%s%s = '
        end
      end

      if self.debug and valIsTable then
        local address = tostring(val):match('table: (.+)')
        str = str .. fstr:format(
          string.rep(self.tab_char, indent + 2),
          color(color.scheme.tableField, key),
          color(color.scheme.debugAddress, address)
        )
      else
        str = str .. fstr:format(
          string.rep(self.tab_char, indent + 2),
          color(color.scheme.tableField, key)
        )
      end

      local success, result = pcall(function()
        return self:wrap(val, indent + 2, seen)
      end)

      if not success then
        result = '<'..color(color.scheme.error, 'error: '..tostring(result))..'>'
      end

      str = str .. result .. ',\n'
    end

    local labelType = ''
    local isArr, arrCount = isArray(obj)

    if isArr then
      labelType = labelType .. ': [array '..arrCount..']'
    end

    str = str..string.rep(self.tab_char, indent)..color(color.scheme.tableBrackets, '}')..labelType

    return str
  else
    return constructor(objType, obj):compile()
  end
end

setmetatable(prettyPrint, { __call = prettyPrint.wrap })

return prettyPrint
