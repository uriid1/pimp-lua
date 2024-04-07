---
-- Table Printing Module
-- @module pretty-print
--
local config = require('pimp.config')
local color = require('pimp.color')
local constructor = require('pimp.constructor')
local metamethods = require('pimp.enums.metamethods')

local prettyPrint = {}

--
local function isArray(tbl)
  if type(tbl) ~= 'table' then
    return false, nil
  end

  local index = 0
  for _,_ in next, tbl do
    index = index + 1

    if tbl[index] == nil then
      return false, nil
    end
  end

  return true, index
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
           :setShowType(config.pretty_print.show_type)
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
      local key_type = type(key)

      -- Detect table
      local valIsTable = type(val) == 'table'

      -- Detect if key is number
      local __field_type
      if key_type == 'string' and tonumber(key) then
        __field_type = '["%s"]'
      elseif key_type == 'number' then
        __field_type = '[%s]'
      else
        __field_type = '%s'
      end

      -- Field color
      local fieldColor = color.scheme.tableField

      if metamethods[key] then
        fieldColor = color.scheme.metatable
      end

      if config.pretty_print.show_table_addr and valIsTable then
        local fmt_str = '%s'
          .. __field_type
          ..': <' .. color(color.scheme.debugAddress, '%s') .. '> = '

        __result = __result
          .. fmt_str:format(
              string.rep(config.pretty_print.tab_char, indent + 2), -- Space
              color(fieldColor, key), -- Field name
              tostring(val) -- Table address
            )
      else
        local fmt_str = '%s'..__field_type..' = '

        __result = __result
          .. fmt_str:format(
              string.rep(config.pretty_print.tab_char, indent + 2), -- Space
              color(fieldColor, key) -- Field name
            )
      end

      local success, error = pcall(function()
        return self:wrap(val, indent + 2, seen)
      end)

      if not success then
        error = '<'..color(color.scheme.error, 'error: '..tostring(error))..'>'
      end

      __result = __result..error..',\n'
    end

    local labelType = ''
    local isArr, arrCount = isArray(obj)

    if isArr and config.pretty_print.show_type then
      labelType = labelType..': [array '..arrCount..']'
    end

    __result = __result
      .. string.rep(config.pretty_print.tab_char, indent)
      .. color(color.scheme.tableBrackets, '}')
      .. labelType

    return __result
  end

  return constructor(__type, obj)
         :setShowType(config.pretty_print.show_type)
         :compile()
end

function prettyPrint:setShowType(val)
  config.pretty_print.show_type = val and true or false

  return self
end

function prettyPrint:setShowTableAddr(val)
  config.pretty_print.show_table_addr = val and true or false

  return self
end

setmetatable(prettyPrint, {
  __call = prettyPrint.wrap,
})

return prettyPrint
