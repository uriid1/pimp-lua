--- Table pretty-printing with highlighting and cycle detection.
local config = require('pimp.config')
local color = require('pimp.color')
local constructor = require('pimp.constructor')
local metamethods = require('pimp.enums.metamethods')
local newBuffer = require('pimp.utils.buffer')

-- Safety limit on the total count of processed elements
local DEFAULT_MAX_SEEN = config.pimp.max_seen

local prettyPrint = {}

--- Check whether a table is an array (sequential numeric keys).
-- @tparam any tbl Value to check
-- @treturn[1] boolean isArray
-- @treturn[1] ?number count Array elements count
local function isArray(tbl)
  if type(tbl) ~= 'table' then
    return false, nil
  end

  local index = 0
  for _ in pairs(tbl) do
    index = index + 1

    if tbl[index] == nil then
      return false, nil
    end
  end

  return true, index
end

--- Check whether a value has a metatable.
-- @tparam any tbl Value to check
-- @treturn boolean hasMt
local function hasMetatable(tbl)
  return getmetatable(tbl) ~= nil
end

--- Table type label: table or metatable.
-- @tparam table tbl Table to label
-- @treturn string prefix
local function tableTypePrefix(tbl)
  if hasMetatable(tbl) then
    return color(color.scheme.metatable, 'metatable')
  end

  return color(color.scheme.tablePrefix, 'table')
end

--- Build a string representation of a value.
-- @tparam any obj Value to print
-- @tparam ?number indent Current indent
-- @tparam ?table seen Tables on the current traversal path (cycle detection)
-- @tparam ?number seenCount Processed elements counter
-- @treturn string result
function prettyPrint:wrap(obj, indent, seen, seenCount)
  local objType = type(obj)
  indent = indent or 0
  seen = seen or {}
  seenCount = seenCount or 0

  if objType == 'nil' then
    return constructor('nil', obj)
      :setShowType(config.pretty_print.show_type)
      :compile()
  end

  if objType ~= 'table' then
    return constructor(objType, obj)
      :setShowType(config.pretty_print.show_type)
      :compile()
  end

  -- Cycle detection: the table has been seen on the current traversal path
  if seen[obj] then
    local address = tostring(obj)
    if address:find('table: ') then
      address = address:match('table: (.+)')
    end

    return '<' .. color(color.scheme.cycleTable, 'cycle: ' .. address) .. '>'
  end

  -- Empty table
  if not next(obj) then
    if config.pretty_print.show_type then
      return color(color.scheme.emptyTable, ('{}: [%s]'):format(tableTypePrefix(obj)))
    end

    return color(color.scheme.emptyTable, '{}')
  end

  seen[obj] = true

  -- Elements count limit, like maxArrayLength in nodejs
  local maxElements = config.pretty_print.max_elements
  local totalElements = nil
  if maxElements and maxElements > 0 then
    totalElements = 0
    for _ in pairs(obj) do
      totalElements = totalElements + 1
    end
  end

  local buf = newBuffer()
  buf:put(color(color.scheme.tableBrackets, '{\n'))

  local shown = 0
  for key, val in pairs(obj) do
    shown = shown + 1

    if totalElements and shown > maxElements then
      buf:put(
        string.rep(config.pretty_print.tab_char, indent + 2),
        '<' .. color(color.scheme.truncated,
          ('... %d more elements'):format(totalElements - maxElements)) .. '>',
        '\n'
      )

      break
    end

    seenCount = seenCount + 1

    if seenCount >= DEFAULT_MAX_SEEN then
      buf:put(
        string.rep(config.pretty_print.tab_char, indent + 2),
        '<' .. color(color.scheme.error, 'Warning: Seen overflow. Rest elements are hidden') .. '>',
        '\n'
      )

      break
    end

    local keyType = type(key)
    local valIsTable = type(val) == 'table'

    -- Key format: a numeric-like string is quoted and bracketed, a number is bracketed
    local fieldType
    if keyType == 'string' and tonumber(key) then
      fieldType = '["%s"]'
    elseif keyType == 'number' then
      fieldType = '[%s]'
    else
      fieldType = '%s'
    end

    -- Metamethod fields get a dedicated color
    local fieldColor = color.scheme.tableField
    if metamethods[key] then
      fieldColor = color.scheme.metatable
    end

    if config.pretty_print.show_table_addr and valIsTable then
      local fmtStr = '%s'
        .. fieldType
        .. ': <' .. color(color.scheme.debugAddress, '%s') .. '> = '

      buf:put(fmtStr:format(
        string.rep(config.pretty_print.tab_char, indent + 2),
        color(fieldColor, key),
        tostring(val)
      ))
    else
      local fmtStr = '%s' .. fieldType .. ' = '

      buf:put(fmtStr:format(
        string.rep(config.pretty_print.tab_char, indent + 2),
        color(fieldColor, key)
      ))
    end

    local ok, wrapped = pcall(function()
      return self:wrap(val, indent + 2, seen, seenCount)
    end)

    if not ok then
      wrapped = '<' .. color(color.scheme.error, 'error: ' .. tostring(wrapped)) .. '>'
    end

    buf:put(wrapped, ',\n')
  end

  -- Array and table type labels
  local labelType = ''
  if config.pretty_print.show_type then
    local isArr, arrCount = isArray(obj)
    if isArr then
      labelType = labelType .. ': [array ' .. color(color.scheme.Number, arrCount) .. ']'
    end
    labelType = labelType .. (': [%s]'):format(tableTypePrefix(obj))
  end

  buf:put(
    string.rep(config.pretty_print.tab_char, indent),
    color(color.scheme.tableBrackets, '}'),
    labelType
  )

  -- The table is fully printed: removal from seen,
  -- so repeated (non-cyclic) references are not labeled as cycle
  seen[obj] = nil

  return buf:tostring()
end

--- Set type labels display.
-- @tparam boolean val Enable or disable
-- @treturn table self
function prettyPrint:setShowType(val)
  config.pretty_print.show_type = val and true or false

  return self
end

--- Set table addresses display.
-- @tparam boolean val Enable or disable
-- @treturn table self
function prettyPrint:setShowTableAddr(val)
  config.pretty_print.show_table_addr = val and true or false

  return self
end

setmetatable(prettyPrint, {
  __call = prettyPrint.wrap,
})

return prettyPrint
