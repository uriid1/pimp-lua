---
-- Table Printing Module
-- @module pretty-print
--
local config = require('pimp.config')
local color = require('pimp.color')
local constructor = require('pimp.constructor')
local metamethods = require('pimp.enums.metamethods')

local prettyPrint = {}

local function isarray(tbl)
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

local function ismt(t)
  return getmetatable(t) ~= nil
end

local function tabletypePrefix(t)
  return ismt(t)
    and color(color.scheme.metatable, 'metatable')
    or color(color.scheme.tablePrefix, 'table')
end

--- Wrap an object for pretty printing
-- obj - any The object to be pretty-printed
-- indent - number The indentation level
-- seen - table A table to keep track of visited objects
function prettyPrint:wrap(obj, indent, seen)
  local _type = type(obj)
  indent = indent or 0
  seen = seen or {}

  if _type == 'nil' then
    return constructor('nil', obj)
      :setShowType(config.pretty_print.show_type)
      :compile()
  end

  if _type == 'table' then
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
      -- Print table type
      if config.pretty_print.show_type then
        return color(color.scheme.emtyTable, ('{}: [%s]'):format(tabletypePrefix(obj)))
      end
      return color(color.scheme.emtyTable, '{}')
    end

    local _result = color(color.scheme.tableBrackets, '{\n')
    for key, val in pairs(obj) do
      local key_type = type(key)

      -- Detect table
      local valIsTable = type(val) == 'table'

      -- Detect if key is number
      local fieldType
      if key_type == 'string' and tonumber(key) then
        fieldType = '["%s"]'
      elseif key_type == 'number' then
        fieldType = '[%s]'
      else
        fieldType = '%s'
      end

      -- Field color
      local fieldColor = color.scheme.tableField

      if metamethods[key] then
        fieldColor = color.scheme.metatable
      end

      if config.pretty_print.show_table_addr and valIsTable then
        local fmt_str = '%s'
          .. fieldType
          ..': <' .. color(color.scheme.debugAddress, '%s') .. '> = '

        _result = _result
          .. fmt_str:format(
              string.rep(config.pretty_print.tab_char, indent + 2), -- Space
              color(fieldColor, key), -- Field name
              tostring(val) -- Table address
            )
      else
        local fmt_str = '%s'..fieldType..' = '

        _result = _result
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

      _result = _result..error..',\n'
    end

    local labelType = ''
    if config.pretty_print.show_type then
      local isArr, arrCount = isarray(obj)
      if isArr then
        labelType = labelType..': [array '..color(color.scheme.Number, arrCount)..']'
      end
      labelType = labelType..(': [%s]'):format(tabletypePrefix(obj))
    end

    _result = _result
      .. string.rep(config.pretty_print.tab_char, indent)
      .. color(color.scheme.tableBrackets, '}')
      .. labelType

    return _result
  end -- if table

  return constructor(_type, obj)
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
