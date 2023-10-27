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
controls[39] = tostring("\\'")

local function string_format(str)
  local res, _ = string.gsub(str, '[%c\1-\39\92]', function (char)
    return controls[string.byte(char, 1)]
  end)

  return res
end

return string_format
