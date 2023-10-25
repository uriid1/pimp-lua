---
-- @module pimp
local pp = require 'pimp.pretty-print'
local type_constructor = require 'pimp.type_constructor'
local color = require 'pimp.color'
local tocolor = color.tocolor

local DEFAULT_PREFIX = 'p'
local DEFAULT_PREFIX_SEP = '|> '
local DEFAULT_MODULE_NAME = 'p'

local pimp = {
  prefix = DEFAULT_PREFIX,
  prefix_sep = DEFAULT_PREFIX_SEP,
  module_name = DEFAULT_MODULE_NAME,
  output = true,
  full_path = true,
  match_path = '',
  colors = true,
}

--
local function char_count(str, char)
  local count = 0
  for i = 1, #str do
    if char == str:sub(i, i) then
      count = count + 1
    end
  end

  return count
end

--- Find the arguments passed to the function
-- @local
-- @param filepath string The path to the file
-- @param call_line number The line number of the function call
-- @return string The found arguments
local stack_find_call = {}
local function find_call(filepath, call_line, curfunc)
  local buff = ''
  local i = 0
  local call_line_non_modify = call_line

  local open_brackets_count = 0 -- (
  local close_brackets_count = 0 -- )

  if not stack_find_call[filepath] then
    stack_find_call[filepath] = {}
    stack_find_call[filepath][call_line_non_modify] = {
      filepath = filepath,
      call_line = call_line_non_modify,
      curfunc = curfunc,
      buff = buff,
      is_func = nil,
    }
  elseif not stack_find_call[filepath][call_line_non_modify] then
    stack_find_call[filepath] = {}
    stack_find_call[filepath][call_line_non_modify] = {
      filepath = filepath,
      call_line = call_line_non_modify,
      curfunc = curfunc,
      buff = buff,
      is_func = nil,
    }
  elseif stack_find_call[filepath][call_line_non_modify] then
    local current = stack_find_call[filepath][call_line_non_modify]
    if curfunc then
      return current.buff:match(curfunc..'%((.+)%)'), true
    end

    return current.buff, current.is_func
  end

  for line in io.lines(filepath) do
    i = i + 1
    -- Start capture
    if i == call_line then
      buff = buff .. line

      open_brackets_count = open_brackets_count + char_count(line, '(')
      close_brackets_count = close_brackets_count + char_count(line, ')')

      if open_brackets_count == close_brackets_count then
        break
      end

      call_line = call_line + 1
    end
  end

  -- Remove spaces
  buff = buff:gsub('  ', '')

  if curfunc then
    return buff:match(curfunc..'%((.+)%)'), true
  end

  -- Capture function and format buffer
  buff = buff:match('.*('..pimp.module_name..'%(.+%))')
  if buff then
    buff = buff:match('%b()')
    buff = buff:match('^%((.-)%)$')
  end

  -- Add to stack
  local current = stack_find_call[filepath][call_line_non_modify]
  current.buff = buff
  if buff then
    current.is_func = buff:match('.+%(.*%)') ~= nil
  else
    current.is_func = false
  end

  return buff, current.is_func
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
  local prefix = self.prefix .. self.prefix_sep

  -- Get information about the calling location
  local info = debug.getinfo(2)

  -- Interactive mode
  if info.source == '=stdin' or info.source == '=[C]' then
    pp(...)
    return ...
  end

  local infunc = ''
  if info.namewhat ~= '' then
    if info.isvararg and info.nparams == 1 then
      info.name = info.name .. '(...)'
    elseif info.linedefined > 0 then
      local filepath = info.source:match('@(.+)')
      local func_args, _ = find_call(filepath, info.linedefined, info.name)
      if func_args then
        info.name = info.name .. '('..func_args..')'
      else
        info.name = info.name .. '(?)'
      end
    else
      info.name = info.name .. '(?)'
    end

    infunc = infunc ..' in '..tocolor(info.name, 'custom_func')
  end

  local linepos = info.currentline
  local filename = info.short_src
  if self.full_path == false then
    filename = filename:match('.+/(.-)$')
  else
    if self.match_path ~= '' then
      local match_path = filename:match(self.match_path)
      if match_path then
        filename = match_path
      end
    end
  end

  local filepath = info.source:match('@(.+)')
  local callpos = filename .. ':' .. linepos

  -- No arguments were passed
  if args_count == 0 then
    io.write(prefix .. callpos .. infunc, '\n')
    io.flush()
    return ...
  end

  -- Handling the 'C' type (for C functions)
  if info.what == 'C' then
    io.write(prefix .. table.concat(args, ', '), '\n')
    io.flush()
    return ...
  end

  -- Find the function call
  local callname, is_func = find_call(filepath, linepos)

  -- Handling a variable number of arguments
  local is_print_agrs_name = true

  if not callname then
    is_print_agrs_name = false
  end

  local data = {}
  for i = 1, args_count do
    local arg = args[i]
    local arg_type = type(arg)
    -- Handle table type
    if arg_type == 'table' then
      local label_type = ''
      table.insert(data, pp:wrap(arg)..label_type)

      if callname and callname:match('{.+}') then
        is_print_agrs_name = false
      end
    else
      local res = type_constructor(arg)
      table.insert(data, res)

      -- For print args
      if arg_type == 'string' or
        arg_type == 'number' or
        arg_type == 'boolean' or
        -- arg_type == 'function' or
        arg_type == 'thread'
      then
        is_print_agrs_name = false
      end
    end
  end

  if is_func then
    local fmt_str = '%s%s: %s: %s\n'
    callname = tocolor(callname, 'custom_func')
    callname = callname .. ' return'
    io.write(fmt_str:format(prefix, callpos, callname, table.concat(data, ', ')))
  else
    local fmt_str = '%s%s: %s\n'
    if is_print_agrs_name then
      io.write(fmt_str:format(prefix, callpos..infunc..': '..callname, table.concat(data, ', ')))
    else
      io.write(fmt_str:format(prefix, callpos..infunc, table.concat(data, ', ')))
    end
  end

  io.flush()
  return ...
end

--- Set prefix and separator
-- @param param Table { prefix='cool', sep='->' }
function pimp:setPrefix(param)
  if param.prefix then
    self.prefix = tostring(param.prefix)
  end
  if param.sep then
    self.prefix_sep = tostring(param.sep)
  end
end

--- Reset prefix
function pimp:resetPrefix()
  self.prefix = DEFAULT_PREFIX
  self.prefix_sep = DEFAULT_PREFIX_SEP
end

--- Enable debug output
function pimp:disable()
  self.output = false
end

--- Disable debug output
function pimp:enable()
  self.output = true
end

--- Matching path
function pimp:matchPath(str)
  self.match_path = tostring(str)
end

--- Disable full path output
function pimp:disableFullPath()
  self.full_path = false
end

--- Enable full path output
function pimp:enableFullPath()
  self.full_path = true
end

--- Disable colour output
function pimp:disableColor()
  self.colors = false
  color.setUseColors(false)
end

--- Enable colour output
function pimp:enableColor()
  self.colors = true
  color.setUseColors(true)
end

---
-- Set up the 'debug' function to be called
-- when attempting to invoke the table as a function
setmetatable(pimp, { __call = pimp.debug })

return pimp
