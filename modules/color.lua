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
  ["userdata"] = "\27[38;5;28m",
  ["thread"] = "\27[0;35m",
  ["function"] = "\27[0;35m",
  ["custom_func"] = "\27[0;34m",
  ["nil"] = "\27[0;35m"
}

local function tocolor(val, type)
  type = type or 'string'

  if type == 'function' then
    return scheme[type]..'<'..tostring(val)..'>'..scheme.reset
  elseif type == 'custom_func' then
    return scheme[type]..tostring(val)..scheme.reset
  elseif type == 'thread' then
    return scheme[type]..'<'..tostring(val)..'>'..scheme.reset
  elseif type == 'table_addr' then
    return scheme[type]..'<'..tostring(val)..'>'..scheme.reset
  elseif type == 'string' then
    val = '\''..val..'\''
  end

  return scheme[type]..tostring(val)..scheme.reset
end

return {
  scheme = scheme,
  tocolor = tocolor,
}
