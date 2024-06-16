local config = require('pimp.config')
local color = require('pimp.color')

local escape = {
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
      c = "00" .. tostring(i)
    else
      c = "0" .. tostring(i)
    end
  end

  controls[i] = tostring('\\' .. c)
end

local function string_format(str)
  if config.string_format.escape_controls then
    controls[92] = tostring('\\\\')
    controls[34] = tostring('\\"')
    controls[39] = tostring("\\'")
  else
    controls[92] = nil
    controls[34] = nil
    controls[39] = nil
  end

  local result = (config.color.use_color and color.scheme.String or '')
  for char in string.gmatch(str, '.') do
    local byte = string.byte(char, 1)
    if controls[byte] then
      result = result .. (config.color.use_color and color.reset or '')
      result = result .. color(color.scheme.controls, controls[byte])
      result = result .. (config.color.use_color and color.scheme.String or '')
    else
      if config.color.use_color then
        if config.string_format.escape_colorize and escape[char] then
          char = color.scheme.escape..char..color.reset..color.scheme.String
        end
      end

      result = result .. char
    end
  end
  result = result .. (config.color.use_color and color.reset or '')

  return result
end

return string_format
