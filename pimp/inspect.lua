local config = require('pimp3.config')
local colors = require('pimp3.colors')

local getlocal = debug.getlocal
local getinfo = debug.getinfo
local getupvalue = debug.getupvalue
local getfenv = debug.getfenv
local colorize = colors.colorize

--- Find variable name by its value
-- @param value The value to find the name for
-- @param level Stack level to search in
-- @return name, isLocal The variable name and whether it's local
local function findVarName(value, level)
  if not config.find_local_name then
    local __type = type(value)

    if not (
        __type == 'function' or
        __type == 'thread'   or
        __type == 'table'    or
        __type == 'userdata'
      )
    then
      return nil, nil
    end
  end

  level = level or 2
  local stack = {}
  local isLocal = false

  -- Search among local variables
  do
    local i = 1
    while true do
      local name, val = getlocal(level, i)

      if name == nil then
        break
      end

      -- Fix: Compare two cdata in tarantool
      local _value = value

      if type(val) == 'cdata' then
        val = tostring(val)
        _value = tostring(value)
      end

      if val == _value then
        table.insert(stack, name)
      end

      i = i + 1
    end
  end

  if stack[1] then
    isLocal = true

    return stack[#stack], isLocal
  end

  -- Search among non-local variables
  local func = getinfo(level, 'f').func

  for i = 1, config.lookup_limit do
    local name, val = getupvalue(func, i)

    if not name then
      break
    end

    if val == value then
      isLocal = true

      return name, isLocal
    end
  end

  -- Search in environment
  local env = getfenv and getfenv(level) or _ENV or _G

  if env ~= nil then
    for name, val in pairs(env) do
      if val == value then
        return name, isLocal
      end
    end
  end

  return nil, isLocal
end

--- Get function arguments as a string
-- @param level Stack level
-- @param nparams Number of parameters
-- @return String representation of function arguments
local function getFuncArgsStr(level, nparams)
  local result = ''

  for i = 1, nparams do
    local name, value = getlocal(level, i)

    if not name then
      break
    end

    -- Check if argument has a metatable
    local __type = type(value)
    local __mt = getmetatable(value)

    -- Strings are defined as metatables
    if __mt and __type ~= 'string' then
      __type = 'metatable'
    end

    if __type == 'string' then
      value = tostring(value)
      value = '[' .. value:len() .. ' byte]'
    elseif
      __type == 'table'     or
      __type == 'metatable' or
      __type == 'userdata'  or
      __type == 'cdata'     or
      __type == 'thread'
    then
      value = '[' .. __type .. ']'
    else
      value = tostring(value)
    end

    result = result .. name .. ': ' .. value

    if i ~= nparams then
     result = result .. ', '
    end
  end

  return result
end

--- Get call stack of functions
-- @param level Stack level to start from
-- @return Formatted call stack string
local function getCallStack(level)
  level = level or 2
  local stack = {}

  for debugLevel = level, config.lookup_limit do
    local info = getinfo(debugLevel)

    if info == nil then
      break
    end

    if info.name ~= nil then
      local funcName = info.name
      local funcArgs = ''
      local visibilityLabel = ''

      if config.show_visibility then
        if info.namewhat ~= '' then
          visibilityLabel = info.namewhat .. ' '
        end
      end

      if info.isvararg then
        if info.nparams == 0 then
          funcArgs = '(...)'
        elseif info.nparams > 0 then
          funcArgs = '(' .. getFuncArgsStr(debugLevel + 1, info.nparams) .. ', ...)'
        end
      else
        if info.nparams == 0 then
          funcArgs = '()'
        elseif info.nparams > 0 then
          funcArgs = '(' .. getFuncArgsStr(debugLevel + 1, info.nparams) .. ')'
        end
      end

      funcName = funcName..funcArgs

      table.insert(stack,
        colorize(visibilityLabel, colors.scheme.visibility)
        .. colorize(funcName, colors.brightMagenta)
      )
    end
  end

  -- Return only the function from which the call was made
  if config.show_full_call_stack == false then
    return stack[2] or ''
  end

  -- Restore call sequence excluding pimp call
  local result = ''
  if config.show_call_stack_ladder == false then
    for i = #stack, 2, -1 do
      if i == 2 then
        result = result .. stack[i]
      else
        result = result .. stack[i] .. config.separator
      end
    end
  else
    result = ''
    for i = #stack, 2, -1 do
      if i == 2 then
        result = result
          .. string.rep(' ', #stack - i)
          .. ('(%d) ↳ '):format(#stack - i + 1)
          .. stack[i]
      elseif i == #stack then
        -- p -> foo/bar.lua:1: [stack count: numer]
        -- (1) ↳ local bar(arg: 0) ➜
        result = result
          .. ('[stack count: %d]'):format(#stack)
          .. string.rep(' ', #stack - i)
          .. ('\n(%d) ↳ '):format(#stack - i + 1)
          .. stack[i] .. config.separator
          .. '\n'
      else
        result = result
          .. string.rep(' ', #stack - i)
          .. ('(%d) ↳ '):format(#stack - i + 1)
          .. stack[i] .. config.separator
          .. '\n'
      end
    end
  end

  return result
end

return {
  findVarName = findVarName,
  getFuncArgsStr = getFuncArgsStr,
  getCallStack = getCallStack
}
