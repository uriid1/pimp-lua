---
-- Logging
-- @module log
--
local color = require('pimp.color')
local write = require('pimp.write')

local log = {}
log.outfile = 'log.txt'
log.usecolor = false
log.ignore = {}
log.match_path = ''

local models = {
  'trace',
  'debug',
  'info',
  'warn',
  'error',
  'fatal'
}

local function writeLog(logData)
  local fd = io.open(log.outfile, 'a')
  fd:write(logData)
  fd:close()
end

local function makeLog(logType, message)
  -- denug info level = 3
  local info = debug.getinfo(3, 'Sl')

  local logFormat = ('[%s %s] ')
    :format(logType, os.date("%H:%M:%S"))

  local path = info.short_src
  if log.match_path then
    path = path:match(log.match_path)
  end

  local colorFormat = color(color.log[logType], logFormat)
  local filePos = path..':'..info.currentline..': '

  if log.usecolor then
    writeLog(colorFormat..filePos..message..'\n')
  else
    writeLog(logFormat..filePos..message..'\n')
  end

  return colorFormat..filePos
end

local function findIgnore(logType)
  for i = 1, #log.ignore do
    local igonoreType = log.ignore[i]
    if igonoreType == logType then
      return true
    end
  end

  return false
end

for i = 1, #models do
  local type = models[i]

  log[type] = function(message)
    if not findIgnore(type) then
      write(makeLog(type, message)..' '.. message)
    end
  end
end

return log
