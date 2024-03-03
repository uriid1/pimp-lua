---
-- Logging
-- @module log
--
local color = require('pimp.color')
local write = require('pimp.write')

local log = {
  outfile = 'log.txt',
  usecolor = false,
  ignore = {},
}

local function writeLog(logData)
  local fd = io.open(log.outfile, 'a')
  fd:write(logData)
  fd:close()
end

local function makeLog(logType, message)
  local level = 3
  local info = debug.getinfo(level)

  local logFormat = ('[%s %s] ')
    :format(logType, os.date("%H:%M:%S"))

  local colorFormat = color(color.log[logType], logFormat)
  local filePos = info.short_src..':'..info.currentline..': '

  if log.usecolor then
    writeLog(colorFormat..filePos..message..'\n')
  else
    writeLog(logFormat..filePos..message..'\n')
  end

  return colorFormat..filePos
end

function log.trace(message)
  local logType = 'TRACE'
  if log.ignore[logType] then return end
  write(makeLog(logType, message), message)
end

function log.debug(message)
  local logType = 'DEBUG'
  if log.ignore[logType] then return end
  write(makeLog(logType, message), message)
end

function log.info(message)
  local logType = 'INFO'
  if log.ignore[logType] then return end
  write(makeLog(logType, message), message)
end

function log.warn(message)
  local logType = 'WARN'
  if log.ignore[logType] then return end
  write(makeLog(logType, message), message)
end

function log.error(message)
  local logType = 'ERROR'
  if log.ignore[logType] then return end
  write(makeLog(logType, message), message)
end

function log.fatal(message)
  local logType = 'FATAL'
  if log.ignore[logType] then return end
  write(makeLog(logType, message), message)
end

return log
