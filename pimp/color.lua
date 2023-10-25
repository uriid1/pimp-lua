---
-- Color Scheme for Text Formatting
--
local colors = true

local scheme = {
  ["reset"] = "\27[0m",

  ["field"] = '\27[36m',
  ["cycle"] = '\27[0;35m',
  ["error"] = '\27[0;91m',
  ["address"] = '\27[0;90m',
  ["table_addr"] = "\27[0;35m",
  ["custom_func"] = "\27[0;34m",
  ["tab_char"] = "\27[38;5;233m",

  ["string"] = "\27[0;93m",
  ["number"] = "\27[38;5;208m",
  ["boolean"] = "\27[38;5;220m",
  ["table"] = "\27[0;37m",
  ["function"] = "\27[0;35m",
  ["thread"] = "\27[0;35m",
  ["userdata"] = "\27[0;36m",
  ["cdata"] = "\27[0;35m",
  ["nil"] = "\27[0;35m",
}

--- Format a value with color according to its type.
-- @param val any The value to be formatted.
-- @param type string The type of the value (optional, default is 'string').
-- @return string The formatted value with color codes.
local function tocolor(val, type)
  type = type or 'string'
  val = tostring(val)

  if type == 'string' then
    val = '\'' .. val .. '\''
  else
    if type == 'table_addr' or
       type == 'function' or
       type == 'thread' or
       type == 'cdata' or
       type == 'userdata'
    then
      val = '<' .. val .. '>'
    end
  end

  if colors == false then
    return val
  end

  if not scheme[type] then
    return scheme['nil'] .. val .. scheme.reset
  end

  return scheme[type] .. val .. scheme.reset
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
