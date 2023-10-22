---
-- Pimp Module
-- @module p
local pp = require 'pimp.pretty-print'
local type_constructor = require 'pimp.type_constructor'
local color = require 'pimp.color'
local tocolor = color.tocolor

local pimp = {
  prefix = nil,
  module_name = 'p',
  output = true,
}

--- Find the arguments passed to the function
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
-- Output debugging information
-- @param ... any Arguments to be printed
-- @return ... The passed arguments
function pimp:debug(...)
  if not self.output then
    return ...
  end

  local args = {...}
  local args_count = #args

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
  if args_count == 0 then
    io.write(self.prefix .. callpos, '\n')
    return ...
  end

  -- Handling the 'C' type (for C functions)
  if info.what == 'C' then
    io.write(self.prefix .. table.concat(args, ', '), '\n')
    return ...
  end

  -- Find the function call
  local callname = find_call(filepath, linepos)

  -- If a function call was the first argument
  if callname:match('.+%(.+%)') ~= nil then
    local args2str = {}
    for i = 1, args_count do
      local arg = args[i]
      table.insert(args2str, type_constructor(arg, args_count))
    end

    local fmt_str = '%s%s: %s: %s\n'
    io.write(
      fmt_str:format(
        self.prefix, callpos, tocolor(callname, 'custom_func'), table.concat(args2str, ', ')
      )
    )
    return ...
  end

  -- Handling a variable number of arguments
  local data = {}
  for i = 1, args_count do
    local arg = args[i]
    local arg_type = type(arg)
    -- Handle table type
    if arg_type == 'table' and args_count == 1 then
      table.insert(data, pp:wrap(arg))
    else
      --
      local res = type_constructor(arg)
      table.insert(data, res)
    end
  end

  local fmt_str = '%s%s: %s\n'
  io.write(fmt_str:format(self.prefix, callpos, table.concat(data, ', ')))
  return ...
end

--- Set prefix
-- @param pref_str Pimp prefix
function pimp:setPrefix(pref_str)
  self.prefix = tostring(pref_str)
end

--- Enable debug output
function pimp:disable()
  self.output = false
end

--- Disable debug output
function pimp:enable()
  self.output = true
end

--- Enable or disable colors
-- @param val boolean
pimp.setUseColors = color.setUseColors

---
-- Set up the 'debug' function to be called
-- when attempting to invoke the table as a function
setmetatable(pimp, { __call = pimp.debug })

return pimp
