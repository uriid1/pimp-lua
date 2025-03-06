--- Module for pretty-printing tables with color formatting and cycle detection
-- @module pretty-print
local config = require('pimp.config')
local color = require('pimp.color')
local constructor = require('pimp.constructor')
local metamethods = require('pimp.enums.metamethods')

--- Maximum number of table elements to process
local DEFAULT_MAX_SEEN = config.pimp.max_seen

--- Main module table
local prettyPrint = {}

--- Check if a table is an array (sequential numeric keys)
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

--- Check if a value has a metatable
local function ismt(t)
  return getmetatable(t) ~= nil
end

--- Get appropriate prefix for table type
local function tabletypePrefix(t)
  return ismt(t)
    and color(color.scheme.metatable, 'metatable')
    or color(color.scheme.tablePrefix, 'table')
end

--- Wrap an object for pretty printing
-- @param obj Any object to be pretty-printed
-- @return string Formatted string representation of the object
function prettyPrint:wrap(obj, indent, seen, seen_count)
  local _type = type(obj)
  indent = indent or 0
  seen = seen or {}
  seen_count = seen_count or 0

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
      seen_count = seen_count + 1

      if seen_count >= DEFAULT_MAX_SEEN then
          local error = 'Seen overflow. Elements count: ' .. tostring(#obj)

          _result = _result
            .. string.rep(config.pretty_print.tab_char, indent + 2)
            .. '<'..color(color.scheme.error, 'Warning: '..tostring(error))..'>'
            .. '\n'

        break
      end

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
        return self:wrap(val, indent + 2, seen, seen_count)
      end)

      if not success then
        error = '<'..color(color.scheme.error, 'error: '..tostring(error))..'>'
      end

      _result = _result..error..',\n'
    end

    local labelType = ''
    if config.pretty_print.show_type then
      local isArr, arrCount = isArray(obj)
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

--- Set whether to show type information
-- @param val Boolean value to enable/disable type display
-- @return self for method chaining
function prettyPrint:setShowType(val)
  config.pretty_print.show_type = val and true or false

  return self
end

--- Set whether to show table addresses
-- @param val Boolean value to enable/disable table address display
-- @return self for method chaining
function prettyPrint:setShowTableAddr(val)
  config.pretty_print.show_table_addr = val and true or false

  return self
end

--- Set metatable to make prettyPrint callable as a function
setmetatable(prettyPrint, {
  __call = prettyPrint.wrap,
})

return prettyPrint
