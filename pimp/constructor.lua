--- Type constructor
--
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

local function constructor(argType, value, argName)
  -- Detect CDATA NULL
  if value and value == nil then
    argType = 'cdata'
  end

  local obj
  if argType == 'number' then
    obj = Number(argName, value)
  elseif argType == 'boolean' then
    obj = Boolean(argName, value)
  elseif argType == 'string' then
    obj = String(argName, value)
  elseif argType == 'function' then
    obj = Function(argName, value)
  elseif argType == 'table' then
    obj = Table(argName, value)
  elseif argType == 'thread' then
    obj = Thread(argName, value)
  elseif argType == 'userdata' then
    obj = Userdata(argName, value)
  elseif argType == 'cdata' then
    obj = Cdata(argName, value)
  elseif argType == 'nil' then
    obj = Nil(argName)
  else
    obj = Unknown(argName)
  end

  return obj
end

return constructor
