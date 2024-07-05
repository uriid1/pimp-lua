--- Модуль для отображения текста в заданном цвете
--
local config = require('pimp.config')
local colorScheme = require('pimp.colorscheme.default')

local color = {}
config.color.use_color = true

-- Adding colors from colorscheme
--
for name, col in pairs(colorScheme.color) do
  color[name] = col
end

color.scheme = {}
for name, col in pairs(colorScheme.scheme) do
  color.scheme[name] = col
end

color.log = {}
for name, col in pairs(colorScheme.log) do
  color.log[name] = col
end
--

function color.colorise(value)
  config.color.use_color = value and true or false
end

function color:tocolor(color_type, value)
  color_type = color_type or self.white

  if config.color.use_color == false then
    return tostring(value)
  end

  return color_type..tostring(value)..color.reset
end

setmetatable(color, { __call = color.tocolor })

return color
