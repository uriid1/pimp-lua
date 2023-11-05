---
-- @module pimp
--
-- Modules
local write = require('pimp.write')
local color = require('pimp.color')
local constructor = require('pimp.constructor')
local prettyPrint = require('pimp.pretty-print')

local DEFAULT_PREFIX = 'p'
local DEFAULT_PREFIX_SEP = '| '
local DEFAULT_MODULE_NAME = 'p'

local pimp = {
  prefix = DEFAULT_PREFIX,
  prefix_sep = DEFAULT_PREFIX_SEP,
  module_name = DEFAULT_MODULE_NAME,
  output = true,
  colors = true,
  full_path = true,
  show_visibility = true,
  match_path = '',
}

--
local seenArg = {}
local function seenAdd(addr, linepos, name)
  if seenArg[addr] then
    seenArg[addr][linepos] = name
    return name
  end

  seenArg[addr] = {}
  seenArg[addr][linepos] = name

  -- debug
  -- write(prettyPrint(seenArg))

  return name
end

local function seenExists(addr, linepos)
  if seenArg[addr] and seenArg[addr][linepos] then
    return true
  end

  return false
end

-- return[1] name string
-- return[2] isLocal boolean
local function findArgName(addr, __type, linepos)
  -- DEBUG
  if not (
      __type == 'function' or
      __type == 'thread'   or
      __type == 'table'    or
      __type == 'userdata'
    )
  then
    return nil, nil
  end

  if seenExists(addr, linepos) then
    return seenArg[addr][linepos]
  end

  -- Find local name by addr
  for i = 1, math.huge do
    local name, value = debug.getlocal(3, i)
    if not name and not value then
      break
    end

    if value == addr then
      return seenAdd(addr, linepos, name), true
    end
  end

  -- Find global name by addr
  for name, value in pairs(_G) do
    if value == addr then
      return seenAdd(addr, linepos, name), false
    end
  end

  return nil, nil
end

---
-- Output debugging information
-- @param ... any Arguments to be printed
-- @return ... The passed arguments
function pimp:debug(...)
  if not self.output then
    return ...
  end

  local argsCount = select('#', ...)
  local prefix = self.prefix .. self.prefix_sep

  -- Get full information about the calling location
  local level = 2
  local info = debug.getinfo(level)

  -- debug
  -- write(prettyPrint(info))

  local infunc = ''
  if info.namewhat ~= '' then
    local funcName = info.name
    local funcArgs = ''
    local visibilityLabel = ''

    if self.show_visibility then
      if info.namewhat == 'local' or
        info.namewhat == 'global'
      then
          visibilityLabel = info.namewhat..' '
      end
    end

    if info.linedefined > 0 then
      if info.nparams > 0 then
        -- Get local func args
        for i = 1, info.nparams do
          local name, value = debug.getlocal(2, i)
          if not name and not value then
            break
          end

          local __type = type(value)
          local __mt = getmetatable(value)
          if __mt then
            __type = 'metatable'
          end

          if __type == 'string' then
            value = tostring(value)
            value = '[' .. value:len()..' byte]'
          elseif
            __type == 'table'     or
            __type == 'metatable' or
            __type == 'userdata'  or
            __type == 'cdata'     or
            __type == 'thread'
          then
            value = '['..__type..']'
          else
            value = tostring(value)
          end

          funcArgs = funcArgs .. name..': '..value
          if i ~= info.nparams then
           funcArgs = funcArgs .. ', '
          end
        end

        funcName = funcName .. '('..funcArgs

        if info.isvararg then
          funcName = funcName .. ', ...'
        end

        funcName = funcName ..')'
      else
        if info.isvararg then
          funcName = funcName .. '(...)'
        else
          funcName = funcName .. '(?)'
        end
      end
    else
      funcName = funcName .. '(?)'
    end

    infunc = infunc
      ..'in '..color(color.scheme.visibility, visibilityLabel)
      ..color(color.brightMagenta, funcName)..': '
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

  -- local filepath = info.source:match('@(.+)')
  local callpos = filename .. ':' .. linepos

  -- Parse
  local data = {}
  for i = 1, argsCount do
    local value = select(i, ...)
    local argType = type(value)
    local argName, isLocal = findArgName(value, argType, linepos)
    local funcArgs = nil

    local obj = constructor(argType, value, argName, funcArgs)

    local visibilityLabel = ''
    if self.show_visibility then
      if isLocal ~= nil then
        visibilityLabel = isLocal and 'local ' or 'global '
        visibilityLabel = color(color.scheme.visibility, visibilityLabel)
      end
    end

    if argType == 'table' then
      local __mt_label = ''
      local __mt = getmetatable(value)
      if __mt then
        __mt_label = ': ['..color(color.scheme.metatable, 'metatable')..']'
      end

      table.insert(data, visibilityLabel..obj:compile()..prettyPrint(value)..__mt_label)
    else
      table.insert(data, visibilityLabel..obj:compile())
    end
  end

  local result = table.concat(data, ', ')

  local delimiter = ' '
  if infunc == '' then
    delimiter = ': '
  end

  write(prefix..callpos..delimiter..infunc..result)

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

  return self
end

--- Reset prefix
function pimp:resetPrefix()
  self.prefix = DEFAULT_PREFIX
  self.prefix_sep = DEFAULT_PREFIX_SEP

  return self
end

--- Enable debug output
function pimp:disable()
  self.output = false

  return self
end

--- Disable debug output
function pimp:enable()
  self.output = true

  return self
end

--- Matching path
function pimp:matchPath(str)
  self.match_path = tostring(str)

  return self
end

--- Disable full path output
function pimp:disableFullPath()
  self.full_path = false

  return self
end

--- Enable full path output
function pimp:enableFullPath()
  self.full_path = true

  return self
end

--- Disable colour output
function pimp:disableColor()
  self.colors = false
  color:colorise(false)

  return self
end

--- Enable colour output
function pimp:enableColor()
  self.colors = true
  color:colorise(true)

  return self
end

--- Enable Visibility
function pimp:enableVisibility()
  self.show_visibility = true

  return self
end

--- Disable Visibility
function pimp:disableVisibility()
  self.show_visibility = false

  return self
end

---
-- Set up the 'debug' function to be called
-- when attempting to invoke the table as a function
setmetatable(pimp, { __call = pimp.debug })

return pimp
