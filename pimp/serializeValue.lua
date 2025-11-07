---
-- Value serializer
---
local stringFormat = require('pimp3.stringFormat')
local StringBuffer = require('pimp3.StringBuffer')
local colors = require('pimp3.colors')
local config = require('pimp3.config')
local inspect = require('pimp3.inspect')
local findVarName = inspect.findVarName

local colorize = colors.colorize

local function serializeValue(value, buffer, opts)
  buffer = buffer or StringBuffer.new()

  local value_type = type(value)

  -- TODO: Можем ли проверить, что интерпритатор luajit?
  -- Если это cdata NULL
  if value and value == nil then
    value_type = 'Cdata'
  end

  if value_type == 'nil' then
    buffer:append(colorize('nil', colors.scheme.Nil))

  elseif value_type == 'table' then
    if opts and opts.table == false then
      return buffer
    end

    local is_empty = next(value) == nil

    if is_empty then
      buffer:append(colorize('{}', colors.scheme.emty_table))
    else
      if config.show_address then
        buffer:append(colorize(('<table [%p]>'):format(value), colors.scheme.nested_table))
      else
        buffer:append(colorize('<table>', colors.scheme.nested_table))
      end
    end

  elseif value_type == 'boolean' then
    buffer:append(colorize(tostring(value), colors.scheme.Boolean))

  elseif value_type == 'number' then
    if value == 1/0 then
      return buffer:append(colorize('<INF>', colors.scheme.Number))
    elseif value == -1/1 then
      return buffer:append(colorize('<-INF>', colors.scheme.Number))
    elseif value ~= value then
      return buffer:append(colorize('<NAN>', colors.scheme.Number))
    end

    buffer:append(colorize(tostring(value), colors.scheme.Number))

  elseif value_type == 'string' then
    local len = #value

    if len > config.max_string_length then
      value = string.sub(value, 1, config.max_string_length) .. '...'
    end

    buffer:append('"' .. stringFormat(value) .. '"')

  elseif value_type == 'function' then
    buffer:append(colorize('<function', colors.scheme.Function))

    local name, islocal = findVarName(value, opts.level + 4)

    if name then
      buffer:append(' ')
      buffer:append(colorize(islocal and 'local' or 'global', colors.scheme.depth))
      buffer:append(' ')
      buffer:append(colorize(name, colors.scheme.Function))
      buffer:append('()')
    end

    if config.show_address then
      buffer:append(colorize(string.format(' [%p]', value), colors.scheme.Function))
    end

    buffer:append(colorize('>', colors.scheme.Function))

  elseif value_type == 'thread' then
    if config.show_address then
      buffer:append(colorize(('<thread [%p]>'):format(value), colors.scheme.Thread))
    else
      buffer:append(colorize('<thread>', colors.scheme.Thread))
    end

  elseif value_type == 'userdata' then
    local fmt = '<userdata>'
    buffer:append(colorize(fmt, colors.scheme.Userdata))

  else
    buffer:append(colorize('<' .. value_type .. '>', colors.scheme.Unknown))
  end

  return buffer
end

return serializeValue
