local color = require('pimp.color')

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

controls[92] = tostring('\\\\')
controls[34] = tostring('\\"')
-- controls[39] = tostring("\\'")

local function string_format(str)
  local result = (color.use_color and color.scheme.String or '')
  for char in string.gmatch(str, '.') do
    local byte = string.byte(char, 1)
    if controls[byte] then
      result = result .. (color.use_color and color.reset or '')
      result = result .. color(color.scheme.controls, controls[byte])
      result = result .. (color.use_color and color.scheme.String or '')
    else
      result = result .. char
    end
  end
  result = result .. (color.use_color and color.reset or '')

  return result
end

return string_format
