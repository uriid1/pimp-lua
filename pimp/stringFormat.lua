local config = require('pimp3.config')
local colors = require('pimp3.colors')

local colorize = colors.colorize

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
  ['$'] = true
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
  [119] = 'w'
}

local special = {
  [7]  = 'a',
  [8]  = 'b',
  [9]  = 't',
  [10] = 'n',
  [11] = 'v',
  [12] = 'f',
  [13] = 'r'
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

local function escapeColorize(char)
  local result = ''

  if config.escape_colorize then
    result = result .. (config.has_colors and colors.reset or '')
    result = result .. colorize(char, colors.scheme.controls)
    result = result .. (config.has_colors and colors.scheme.String or '')

    return result
  end

  return char
end

local function patternColorize(str, cur_pos, char)
  if config.pattern_colorize == false then
    return char
  end

  local result = ''

  -- Поиск паттернов
  -- %w, %a, ...
  local prev_byte = string.byte(str, cur_pos - 1)
  local cur_byte = string.byte(str, cur_pos)

  -- 37 %
  if prev_byte == 37 then
    if patterns[cur_byte] then
      result = result .. (config.has_colors and colors.reset or '')
      result = result .. colorize(char, colors.scheme.pattern)
      result = result .. (config.has_colors and colors.scheme.String or '')

      return result
    end
  end

  local next_byte = string.byte(str, cur_pos + 1)
  if magics[char] then
    local color_type = colors.scheme.magic
    -- 37 %
    if cur_byte == 37 and patterns[next_byte] then
      color_type = colors.scheme.pattern
    end

    result = result .. (config.has_colors and colors.reset or '')
    result = result .. colorize(char, color_type)
    result = result .. (config.has_colors and colors.scheme.String or '')

    return result
  end

  return char
end

local function stringFormat(str)
  local result = (config.has_colors and colors.scheme.String or '')

  -- Экранирование специальных символов
  if config.escape_controls then
    for i = 1, #str do
      local char = string.sub(str, i, i)
      local byte = string.byte(char, 1)

      if byte < 128 then
        if controls[byte] then
          result = result .. escapeColorize(controls[byte])
        else
          result = result .. patternColorize(str, i, char)
        end

      elseif byte < 256 then
        if config.escape_non_ascii then
          result = result .. escapeColorize('\\' .. byte, true)
        else
          result = result .. char
        end
      end
    end
  elseif config.escape_non_ascii then
    for i = 1, #str do
      local char = string.sub(str, i, i)
      local byte = string.byte(char, 1)

      if byte > 128 and byte < 256 then
        result = result .. escapeColorize('\\' .. byte, true)
      else
        result = result .. char
      end
    end
  else
    result = result .. str
  end

  result = result .. (config.has_colors and colors.reset or '')

  return result
end

return stringFormat
