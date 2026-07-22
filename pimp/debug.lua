--- Debug output core: variable name lookup, call stack,
--- result assembly and printing.
--
-- IMPORTANT: the debug function must be called directly (through the __call
-- of the pimp table or as the p:debug method), without intermediate wrappers -
-- stack levels for debug.getlocal and getinfo rely on exactly this call depth.
local config = require('pimp.config')
local write = require('pimp.write')
local color = require('pimp.color')
local constructor = require('pimp.constructor')
local prettyPrint = require('pimp.pretty_print')
local makePath = require('pimp.utils.make_path')
local sourceNames = require('pimp.utils.source_names')

-- Safety limit on entries count during traversals
local DEFAULT_MAX_SEEN = config.pimp.max_seen

local getlocal = debug.getlocal
local getinfo = debug.getinfo
local getupvalue = debug.getupvalue
local getfenv = debug.getfenv -- Lua 5.1 / LuaJIT only

local pimpDebug = {}

--- Find a variable name by its value.
-- The search goes through locals, upvalues and the environment.
-- For primitive types it works only when the find_local_name flag is on:
-- a match by value does not guarantee the name corresponds to the value.
-- @tparam any value Value to find the name for
-- @tparam ?number level Stack level to search at
-- @treturn[1] string name Found name
-- @treturn[1] ?boolean isLocal Local variable flag
-- @treturn[2] nil
local function findVarName(value, level)
  if not config.pimp.find_local_name then
    local valueType = type(value)
    local isReference = valueType == 'function'
      or valueType == 'thread'
      or valueType == 'table'
      or valueType == 'userdata'

    if not isReference then
      return nil, nil
    end
  end

  level = level or 2
  local stack = {}
  local isLocal = false

  -- Search among local variables
  local i = 1
  while true do
    local name, val = getlocal(level, i)
    if name == nil then
      break
    end

    -- Two cdata values in Tarantool can be compared only through tostring
    local compareValue = value
    if type(val) == 'cdata' then
      val = tostring(val)
      compareValue = tostring(value)
    end

    if val == compareValue then
      table.insert(stack, name)
    end

    i = i + 1
  end

  if stack[1] then
    isLocal = true
    return stack[#stack], isLocal
  end

  -- Search among upvalues
  local info = getinfo(level, 'f')
  local func = info and info.func

  if func then
    for upIndex = 1, DEFAULT_MAX_SEEN do
      local name, val = getupvalue(func, upIndex)
      if not name then
        break
      end

      if val == value then
        isLocal = true
        return name, isLocal
      end
    end
  end

  -- Search in the environment
  local env = nil

  if getfenv then
    env = getfenv(level)
  elseif _ENV then
    env = _ENV
  elseif _G then
    env = _G
  end

  if env ~= nil then
    for name, val in pairs(env) do
      if val == value then
        return name, isLocal
      end
    end
  end

  return nil, isLocal
end

--- Build the function arguments string for the call stack.
-- @tparam number level Stack level
-- @tparam number nparams Function parameters count
-- @treturn string result String of the form 'name: value, ...'
local function getFuncArgsStr(level, nparams)
  local result = ''

  for i = 1, nparams do
    local name, value = getlocal(level, i)
    if not name then
      break
    end

    local argType = type(value)
    local mt = getmetatable(value)

    -- Strings have a default metatable, it does not concern them
    if mt and argType ~= 'string' then
      argType = 'metatable'
    end

    if argType == 'string' then
      value = '[' .. #value .. ' byte]'
    elseif argType == 'table'
      or argType == 'metatable'
      or argType == 'userdata'
      or argType == 'cdata'
      or argType == 'thread'
    then
      value = '[' .. argType .. ']'
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

--- Build the formatted call stack.
-- @tparam ?number level Stack level to start the traversal from
-- @tparam string separator Separator between stack entries
-- @treturn string result
local function getCallStack(level, separator)
  level = level or 2
  local stack = {}

  for debugLevel = level, DEFAULT_MAX_SEEN do
    local info = getinfo(debugLevel)

    if info == nil then
      break
    end

    if info.name ~= nil then
      local funcName = info.name
      local funcArgs = ''
      local visibilityLabel = ''

      if config.pimp.show_visibility then
        if info.namewhat ~= '' then
          visibilityLabel = info.namewhat .. ' '
        end
      end

      -- Lua 5.1 does not report nparams and isvararg through getinfo
      if info.nparams == nil then
        funcArgs = '()'
      elseif info.isvararg then
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
      funcName = funcName .. funcArgs

      table.insert(stack,
        color(color.scheme.visibility, visibilityLabel) .. color(color.brightMagenta, funcName)
      )
    end
  end

  -- Only the function the call was made from
  if config.pimp.show_full_call_stack == false then
    return stack[2] or ''
  end

  -- Call sequence reconstruction excluding the pimp call itself
  local result = ''
  if config.pimp.show_call_stack_ladder == false then
    for i = #stack, 2, -1 do
      if i == 2 then
        result = result .. stack[i]
      else
        result = result .. stack[i] .. separator
      end
    end

    return result
  end

  -- Ladder-style rendering:
  -- p -> foo/bar.lua:1: [stack count: 2]
  -- (1) - local bar(arg: 0) ->
  --  (2) - foo()
  for i = #stack, 2, -1 do
    if i == 2 then
      result = result
        .. string.rep(' ', #stack - i)
        .. ('(%d) ↳ '):format(#stack - i + 1)
        .. stack[i]
    elseif i == #stack then
      result = result
        .. ('[stack count: %d]'):format(#stack)
        .. string.rep(' ', #stack - i)
        .. ('\n(%d) ↳ '):format(#stack - i + 1)
        .. stack[i] .. separator
        .. '\n'
    else
      result = result
        .. string.rep(' ', #stack - i)
        .. ('(%d) ↳ '):format(#stack - i + 1)
        .. stack[i] .. separator
        .. '\n'
    end
  end

  return result
end

--- Print values with the call context.
-- Called as pimp:debug(...) or through the __call of the pimp table.
-- @tparam table self The pimp table with prefix and separator fields
-- @tparam any ... Values to print
-- @treturn any ... Input values unchanged (for chaining)
function pimpDebug.debug(self, ...)
  if not config.pimp.output then
    return ...
  end

  local level = 2
  local info = getinfo(level, 'lS')
  if info == nil then
    level = 1
    info = getinfo(level, 'lS')
  end

  local callpos = makePath(info) .. ':' .. info.currentline
  local prefix = self.prefix .. self.separator
  local argsCount = select('#', ...)

  -- Argument names from the call-site source line
  local srcNames
  if config.pimp.find_name_from_source then
    local aliasName = findVarName(self, level + 1)
    local names, namesCount = sourceNames(info, aliasName)

    -- Names apply only when every value has its own expression:
    -- with p(f()) one expression may produce several values
    if names ~= nil and namesCount == argsCount then
      srcNames = names
    end
  end

  local varargsCompiled = {}
  for i = 1, argsCount do
    local argValue = select(i, ...)
    local argType = type(argValue)

    local argName
    local isLocal
    if srcNames and srcNames[i] then
      argName = srcNames[i]
    else
      argName, isLocal = findVarName(argValue, level + 1)
    end

    local obj = constructor(argType, argValue, argName)
    obj:setShowType(config.pimp.show_type)

    local visibilityLabel = ''
    if config.pimp.show_visibility then
      if isLocal ~= nil then
        visibilityLabel = isLocal and 'local ' or 'global '
        visibilityLabel = color(color.scheme.visibility, visibilityLabel)
      end
    end

    if argType == 'table' then
      prettyPrint:setShowType(config.pimp.show_type)
      prettyPrint:setShowTableAddr(config.pimp.show_table_addr)
      obj:setShowTableAddr(config.pimp.show_table_addr)

      table.insert(varargsCompiled, visibilityLabel .. obj:compile() .. prettyPrint(argValue))
    else
      table.insert(varargsCompiled, visibilityLabel .. obj:compile())
    end
  end

  local stackStr = getCallStack(level, self.separator)
  local result = table.concat(varargsCompiled, ', ')

  write(
    prefix
    .. callpos .. ': '
    .. (stackStr == '' and '' or stackStr .. ': ')
    .. result
  )

  return ...
end

--- Collect local variables at the given stack level.
-- @tparam ?number level Stack level
-- @treturn table env Name -> value table
function pimpDebug.getLocalEnv(level)
  level = level or 2
  local i = 1
  local env = {}

  while true do
    local name, value = getlocal(level, i)
    if not name then
      break
    end

    env[name] = value
    i = i + 1
  end

  return env
end

return pimpDebug
