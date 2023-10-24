---
-- Color Scheme for Text Formatting
--
local colors = true

local scheme = {
  ["reset"] = "\27[0m",

  ["field"] = '\27[0;37m',
  ["cycle"] = '\27[0;35m',
  ["error"] = '\27[0;91m',
  ["address"] = '\27[0;90m',

  ["string"] = "\27[0;93m",
  ["number"] = "\27[38;5;208m",
  ["boolean"] = "\27[38;5;220m",
  ["table_addr"] = "\27[0;35m",
  ["table"] = "\27[0;37m",
  ["userdata"] = "\27[0;36m",
  ["thread"] = "\27[0;35m",
  ["function"] = "\27[0;35m",
  ["cdata"] = "\27[0;35m",
  ["custom_func"] = "\27[0;34m",
  ["nil"] = "\27[0;35m",
}

--- Format a value with color according to its type.
-- @param val any The value to be formatted.
-- @param type string The type of the value (optional, default is 'string').
-- @return string The formatted value with color codes.
local function tocolor(val, type)
  type = type or 'string'

  if colors then
    if type == 'function' then
      return scheme[type] .. '<' .. tostring(val) .. '>' .. scheme.reset
    elseif type == 'custom_func' then
      return scheme[type] .. tostring(val) .. scheme.reset
    elseif type == 'thread' then
      return scheme[type] .. '<' .. tostring(val) .. '>' .. scheme.reset
    elseif type == 'table_addr' then
      return scheme[type] .. '<' .. tostring(val) .. '>' .. scheme.reset
    elseif type == 'string' then
      val = '\'' .. val .. '\''
    end

    if scheme[type] then
      return scheme[type] .. tostring(val) .. scheme.reset
    end

    return scheme['nil'] .. tostring(val) .. scheme.reset
  end

  if type == 'function' then
    return '<' .. tostring(val) .. '>'
  elseif type == 'custom_func' then
    return tostring(val)
  elseif type == 'thread' then
    return '<' .. tostring(val) .. '>'
  elseif type == 'table_addr' then
    return '<' .. tostring(val) .. '>'
  elseif type == 'string' then
    val = '\'' .. val .. '\''
  end

  return tostring(val)
end

--- Enable or disable colors
-- @param val boolean
local function setUseColors(val)
  colors = val and true or false
end

--- Module for Text Color Formatting.
-- @table color
-- @field scheme Table The color scheme used for formatting.
-- @field tocolor Function to format text with color.
-- @field setUseColors Function to set use or unuse color sheme.

return {
  scheme = scheme,
  tocolor = tocolor,
  setUseColors = setUseColors,
}
