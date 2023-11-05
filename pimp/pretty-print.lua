---
-- Table Printing Module
-- @module pretty-print
--
local color = require 'pimp.color'
local constructor = require 'pimp.constructor'

local prettyPrint = {
  tab_char = ' ',
  show_type = true,
  show_table_addr = false,
}

local metamethods = {
  ["__call"] = true,
  ["__concat"] = true,
  ["__tostring"] = true,
  ["__metatable"] = true,
  ["__mode"] = true,
  ["__gc"] = true,

  ["__index"] = true,
  ["__newindex"] = true,

  ["__add"] = true,
  ["__sub"] = true,
  ["__mul"] = true,
  ["__div"] = true,
  ["__pow"] = true,
  ["__mod"] = true,
  ["__unm"] = true,

  ["__eq"] = true, -- ==
  ["__lt"] = true, -- <
  ["__lе"] = true, -- <=

  ["__len"] = true,
  ["__ipairs"] = true,

  -- 5.3
  ["__band"] = true, -- &
  ["__bor"] = true, -- |
  ["__bxor"] = true, -- ~
  ["__bnot"] = true, -- ~
  ["__shl"] = true, -- <<
  ["__shr"] = true, -- >>

  ["__idiv"] = true,
}

--
local function isArray(t)
  if type(t) ~= 'table' then
    return false
  end

  local count = 1
  for index in next, t do
    if type(index) ~= 'number' then
      return false, nil
    end

    count = count + 1
  end

  return true, count-1
end

--- Wrap an object for pretty printing
-- @param obj any The object to be pretty-printed
-- @param indent number The indentation level (optional, default is 0)
-- @param seen table A table to keep track of visited objects (optional)
-- @return string The pretty-printed string
function prettyPrint:wrap(obj, indent, seen)
  local __type = type(obj)
  indent = indent or 0
  seen = seen or {}

  if __type == 'nil' then
    return constructor('nil', obj)
           :setShowType(self.show_type)
           :compile()
  end

  if __type == 'table' then
    -- Check if we've already seen this table
    if seen[obj] then
      local address = tostring(obj)
      if address:find('table: ') then
        address = address:match('table: (.+)')
      end
      return '<'..color(color.scheme.cycleTable, 'cycle: '..address)..'>'
    end
    seen[obj] = true

    -- Detect empty table
    if not next(obj) then
      return color(color.scheme.emtyTable, '{}')
    end

    local __result = color(color.scheme.tableBrackets, '{\n')
    for key, val in pairs(obj) do
      -- Detect table
      local valIsTable = type(val) == 'table'

      -- Detect if key is number
      local __field_type = tonumber(key) and '[%s]' or '%s'

      -- Field color
      local fieldColor = color.scheme.tableField

      if metamethods[key] then
        fieldColor = color.scheme.metatable
      end

      if self.show_table_addr and valIsTable then
        local fmt_str = '%s'..__field_type..' %s = '
        local address = tostring(val):match('^table: (.+)$')

        __result = __result
          .. fmt_str:format(
              string.rep(self.tab_char, indent + 2),    -- Space
              color(fieldColor, key),                   -- Field name
              color(color.scheme.debugAddress, address) -- Table address
            )
      else
        local fmt_str = '%s'..__field_type..' = '

        __result = __result
          .. fmt_str:format(
              string.rep(self.tab_char, indent + 2), -- Space
              color(fieldColor, key)                 -- Field name
            )
      end

      local success, error = pcall(function()
        return self:wrap(val, indent + 2, seen)
      end)

      if not success then
        error = '<'..color(color.scheme.error, 'error: '..tostring(error))..'>'
      end

      __result = __result .. error .. ',\n'
    end

    local labelType = ''
    local isArr, arrCount = isArray(obj)

    if isArr and self.show_type then
      labelType = labelType .. ': [array '..arrCount..']'
    end

    __result = __result
      .. string.rep(self.tab_char, indent)
      .. color(color.scheme.tableBrackets, '}')
      .. labelType

    return __result
  end

  return constructor(__type, obj)
         :setShowType(self.show_type)
         :compile()
end

function prettyPrint:setShowType(val)
  self.show_type = val and true or false

  return self
end

function prettyPrint:setShowTableAddr(val)
  self.show_table_addr = val and true or false

  return self
end

setmetatable(prettyPrint, {
  __call = prettyPrint.wrap,
})

return prettyPrint
