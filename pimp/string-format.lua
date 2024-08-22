local config = require('pimp.config')
local color = require('pimp.color')

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

local special = {
  [7]  = 'a',
  [8]  = 'b',
  [9]  = 't',
  [10] = 'n',
  [11] = 'v',
  [12] = 'f',
  [13] = 'r',
}

local controls = {}
for i = 0, 31 do
  local c = special[i]
  if not c then
    if i < 10 then
      c = '00' .. tostring(i)
    else
      c = '0' .. tostring(i)
    end
  end

  controls[i] = tostring('\\' .. c)
end

-- 127 DEL
controls[127] = tostring('\\127')
-- 34 "
controls[34] = tostring('\\"')

local function escape_colorize(char, colorize)
  local result = ''
  if colorize then
    result = result .. (config.color.use_color and color.reset or '')
    result = result .. color(color.scheme.controls, char)
    result = result .. (config.color.use_color and color.scheme.String or '')
    return result
  end

  return char
end

local function pattern_colorize(str, cur_pos, char, colorize)
  if colorize then
    local result = ''

    -- Поиск паттернов
    -- %w, %a, ...
    local prev_byte = string.byte(str, cur_pos-1)
    local cur_byte = string.byte(str, cur_pos)
    -- 37 %
    if prev_byte == 37 then
      if patterns[cur_byte] then
        result = result .. (config.color.use_color and color.reset or '')
        result = result .. color(color.scheme.pattern, char)
        result = result .. (config.color.use_color and color.scheme.String or '')
        return result
      end
    end

    local next_byte = string.byte(str, cur_pos+1)
    if magics[char] then
      local color_type = color.scheme.magic
      -- 37 %
      if cur_byte == 37 and patterns[next_byte] then
        color_type = color.scheme.pattern
      end

      result = result .. (config.color.use_color and color.reset or '')
      result = result .. color(color_type, char)
      result = result .. (config.color.use_color and color.scheme.String or '')
      return result
    end
  end

  return char
end

local function string_format(str)
  local result = (config.color.use_color and color.scheme.String or '')
  for i = 1, #str do
    local char = string.sub(str, i, i)
    local byte = string.byte(char, 1)

    -- Экранирование спец.символов
    if config.string_format.escape_controls then
      if byte < 128 then
        if controls[byte] then
          result = result .. escape_colorize(controls[byte], config.string_format.escape_colorize)
        else
          result = result .. pattern_colorize(str, i, char, config.string_format.patterns_colorize)
        end
      elseif byte < 256 then
        if config.string_format.escape_non_ascii then
          result = result .. escape_colorize('\\'..byte, true)
        else
          result = result .. char
        end
      end
    end
  end

  result = result .. (config.color.use_color and color.reset or '')

  return result
end

return string_format
