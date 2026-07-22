--- String formatting: escaping and highlighting.
local config = require('pimp.config')
local color = require('pimp.color')
local newBuffer = require('pimp.utils.buffer')

-- Magic characters of lua patterns
local magics = {
  ['-'] = true,
  ['%'] = true,
  ['('] = true,
  [')'] = true,
  ['.'] = true,
  ['+'] = true,
  ['*'] = true,
  ['?'] = true,
  ['['] = true,
  [']'] = true,
  ['^'] = true,
  ['$'] = true,
}

-- Bytes of lua pattern class letters (%a, %w, ...)
local patterns = {
  [65] = 'A',
  [66] = 'B',
  [67] = 'C',
  [68] = 'D',
  [70] = 'F',
  [71] = 'G',
  [76] = 'L',
  [80] = 'P',
  [83] = 'S',
  [85] = 'U',
  [87] = 'W',
  [97] = 'a',
  [98] = 'b',
  [99] = 'c',
  [100] = 'd',
  [102] = 'f',
  [103] = 'g',
  [108] = 'l',
  [112] = 'p',
  [115] = 's',
  [117] = 'u',
  [119] = 'w',
}

-- Control characters with a conventional escape form
local special = {
  [7] = 'a',
  [8] = 'b',
  [9] = 't',
  [10] = 'n',
  [11] = 'v',
  [12] = 'f',
  [13] = 'r',
}

-- Escape table of control characters: byte -> '\n', '\007', ...
local controls = {}
for i = 0, 31 do
  local char = special[i]
  if not char then
    if i < 10 then
      char = '00' .. tostring(i)
    else
      char = '0' .. tostring(i)
    end
  end

  controls[i] = '\\' .. char
end

controls[127] = '\\127' -- DEL
controls[34] = '\\"' -- Double quote

--- Colorize an escaped character.
-- @tparam string char Escaped character form
-- @tparam boolean colorize Colorization flag
-- @treturn string result
local function escapeColorize(char, colorize)
  if not colorize then
    return char
  end

  local result = ''
  result = result .. (config.color.use_color and color.reset or '')
  result = result .. color(color.scheme.controls, char)
  result = result .. (config.color.use_color and color.scheme.String or '')

  return result
end

--- Colorize magic characters and lua pattern classes.
-- @tparam string str Source string
-- @tparam number curPos Current character position
-- @tparam string char Current character
-- @tparam boolean colorize Colorization flag
-- @treturn string result
local function patternColorize(str, curPos, char, colorize)
  if not colorize then
    return char
  end

  -- Pattern class: %w, %a, ... (37 - byte of the % character)
  local prevByte = string.byte(str, curPos - 1)
  local curByte = string.byte(str, curPos)

  if prevByte == 37 and patterns[curByte] then
    local result = ''
    result = result .. (config.color.use_color and color.reset or '')
    result = result .. color(color.scheme.pattern, char)
    result = result .. (config.color.use_color and color.scheme.String or '')

    return result
  end

  if magics[char] then
    local nextByte = string.byte(str, curPos + 1)
    local colorType = color.scheme.magic

    if curByte == 37 and patterns[nextByte] then
      colorType = color.scheme.pattern
    end

    local result = ''
    result = result .. (config.color.use_color and color.reset or '')
    result = result .. color(colorType, char)
    result = result .. (config.color.use_color and color.scheme.String or '')

    return result
  end

  return char
end

--- Format a string with escaping and highlighting.
-- @tparam string str Source string
-- @treturn string formatted Formatted string (possibly truncated)
-- @treturn number truncated Number of bytes left out of the output
local function stringFormat(str)
  -- Long string truncation, like maxStringLength in nodejs
  local maxLength = config.string_format.max_length
  local truncated = 0
  if maxLength and maxLength > 0 and #str > maxLength then
    truncated = #str - maxLength
    str = str:sub(1, maxLength)
  end

  local buf = newBuffer()
  buf:put(config.color.use_color and color.scheme.String or '')

  for i = 1, #str do
    local char = string.sub(str, i, i)
    local byte = string.byte(char, 1)

    if byte < 128 then
      if controls[byte] and config.string_format.escape_controls then
        buf:put(escapeColorize(controls[byte], config.string_format.escape_colorize))
      elseif controls[byte] then
        buf:put(char)
      else
        buf:put(patternColorize(str, i, char, config.string_format.patterns_colorize))
      end
    else
      if config.string_format.escape_non_ascii then
        buf:put(escapeColorize('\\' .. byte, true))
      else
        buf:put(char)
      end
    end
  end

  buf:put(config.color.use_color and color.reset or '')

  return buf:tostring(), truncated
end

return stringFormat
