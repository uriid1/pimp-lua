--
-- Type constructor
--
local color = require 'pimp.color'
local tocolor = color.tocolor

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

-- Maybe?
-- for i = 128, 255 do
--   local c
--   if i < 100 then
--     c = "0" .. tostring(i)
--   else
--     c = tostring(i)
--   end

--   controls[i] = tostring('\\' .. c)
-- end

local function stringEscape(c)
  return controls[string.byte(c, 1)]
end

--- Determine the type of an argument and format it
-- @local
-- @param arg any The argument
-- @return string The formatted argument
local function type_constructor(arg)
  local arg_type = type(arg)

  if arg_type == 'table' then
    -- If a table is passed
    return tocolor(tostring(arg), 'table_addr')
  elseif arg_type == 'number' then
    -- If a number is passed
    return tocolor(tostring(arg), arg_type) .. ': [number]'
  elseif arg_type == 'function' then
    -- If a function address is passed
    return tocolor(tostring(arg), arg_type)
  elseif arg_type == 'string' then
    -- If a string is passed
    arg = string.gsub(arg, '[%c]', stringEscape)
    return tocolor(arg) .. ': [length ' .. tostring(#arg) .. ']'
  elseif arg_type == 'thread' then
    -- If a thread is passed
    return tocolor(tostring(arg), arg_type)
  elseif arg_type == 'boolean' then
    -- If a boolean value is passed
    return tocolor(tostring(arg), arg_type) .. ': [boolean]'
  elseif arg_type == 'cdata' then
    -- If a cdata is passed
    return tocolor(tostring(arg), arg_type) .. ': [cdata]'
  elseif arg_type == 'userdata' then
    -- If a userdata is passed
    return tocolor(tostring(arg), arg_type) .. ': [userdata]'
  else
    -- If nil, cdata, or an unknown type is passed
    return tocolor(tostring(arg), arg_type) .. ': [undefended]'
  end
end

return type_constructor
