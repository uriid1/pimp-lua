--- Wrapper object constructor dispatched by value type.
local Number = require('pimp.classes.Number')
local String = require('pimp.classes.String')
local Boolean = require('pimp.classes.Boolean')
local Function = require('pimp.classes.Function')
local Table = require('pimp.classes.Table')
local Thread = require('pimp.classes.Thread')
local Userdata = require('pimp.classes.Userdata')
local Cdata = require('pimp.classes.Cdata')
local Nil = require('pimp.classes.Nil')
local Unknown = require('pimp.classes.Unknown')

--- Create a wrapper object for a value.
-- @tparam string argType Value type (result of type)
-- @tparam any value Value to wrap
-- @tparam ?string argName Variable name
-- @treturn table obj
local function constructor(argType, value, argName)
  -- cdata NULL: the value is truthy yet equals nil (LuaJIT/Tarantool)
  if value and value == nil then
    argType = 'cdata'
  end

  if argType == 'number' then
    return Number(argName, value)
  elseif argType == 'boolean' then
    return Boolean(argName, value)
  elseif argType == 'string' then
    return String(argName, value)
  elseif argType == 'function' then
    return Function(argName, value)
  elseif argType == 'table' then
    return Table(argName, value)
  elseif argType == 'thread' then
    return Thread(argName, value)
  elseif argType == 'userdata' then
    return Userdata(argName, value)
  elseif argType == 'cdata' then
    return Cdata(argName, value)
  elseif argType == 'nil' then
    return Nil(argName)
  end
  return Unknown(argName)
end

return constructor
