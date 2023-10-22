---
-- Pimp Module
-- @module p
local pp = require 'modules.pretty-print'
local color = require 'modules.color'
local tocolor = color.tocolor

local pimp = {
  prefix = nil,
  module_name = 'p',
}

---
-- Find the arguments passed to the function
-- @local
-- @param filepath string The path to the file
-- @param call_line number The line number of the function call
-- @return string The found arguments
local function find_call(filepath, call_line)
  local i = 0
  for line in io.lines(filepath) do
    i = i + 1
    if i == call_line then
      local fdata = line:match(pimp.module_name .. '%((.+)%)')
      return fdata
    end
  end
end

---
-- Determine the type of an argument and format it
-- @local
-- @param arg any The argument
-- @param args_count number The number of arguments
-- @return string The formatted argument
local function type_constructor(arg, args_count)
  local arg_type = type(arg)

  if arg_type == 'table' then
    -- If a table is passed
    if args_count then
      if args_count > 1 then
        return tocolor(tostring(arg), 'table_addr')
      end
    end

    -- Pretty-print the table
    return pp:wrap(arg)
  elseif arg_type == 'number' then
    -- If a number is passed
    return tocolor(tostring(arg), arg_type) .. ': [number]'
  elseif arg_type == 'function' then
    -- If a function address is passed
    return tocolor(tostring(arg), arg_type)
  elseif arg_type == 'string' then
    -- If a string is passed
    return tocolor(arg) .. ': [length ' .. tostring(#arg) .. ']'
  elseif arg_type == 'thread' then
    -- If a thread is passed
    return tocolor(tostring(arg), arg_type)
  elseif arg_type == 'boolean' then
    -- If a boolean value is passed
    return tocolor(tostring(arg), arg_type) .. ': [boolean]'
  else
    -- If nil, cdata, or an unknown type is passed
    return tocolor(tostring(arg), arg_type) .. ': [type undefended]'
  end
end

---
-- Output debugging information
-- @param ... any Arguments to be printed
-- @return ... The passed arguments
function pimp:debug(...)
  local args = {...}

  -- Set the prefix based on the loaded module's name
  if not self.prefix then
    local info = debug.getinfo(1, 'n')
    self.prefix = info.name .. '| '
    self.module_name = info.name
  end

  -- Get information about the calling location
  -- S - source, short_src, what, linedefined, lastlinedefined
  -- L - currentline
  local info = debug.getinfo(2, 'Sl')

  local linepos = info.currentline
  local filename = info.short_src
  local filepath = info.source:match('@(.+)')
  local callpos = filename .. ':' .. linepos

  -- No arguments were passed
  if #args == 0 then
    io.write(self.prefix .. callpos, '\n')
    return ...
  end

  -- Handling the 'C' type (for C functions)
  local type = info.what
  if type == 'C' then
    io.write(self.prefix .. table.concat(args, ', '), '\n')
    return ...
  end

  -- Find the function call
  local callname = find_call(filepath, linepos)

  if #args == 1 then
    -- If a function call was the first argument
    if callname:match('.+%(.+%)') ~= nil then
      local fmt_str = '%s%s: %s: %s\n'
      io.write(fmt_str:format(self.prefix, callpos, tocolor(callname, 'custom_func'), ...))
      return ...
    end

    -- Determine the type of the first argument
    local res = type_constructor(args[1])
    local fmt_str = '%s%s: %s\n'
    io.write(fmt_str:format(self.prefix, callpos, res))
    return ...
  end

  -- Handling a variable number of arguments
  local data = {}
  for i = 1, #args do
    local arg = args[i]
    local res = type_constructor(arg, #args)
    table.insert(data, res)
  end

  local fmt_str = '%s%s: %s\n'
  io.write(fmt_str:format(self.prefix, callpos, table.concat(data, ', ')))
  return ...
end

---
-- Set up the 'debug' function to be called
-- when attempting to invoke the table as a function
setmetatable(pimp, { __call = pimp.debug })

return pimp
