--
-- Отображения текста в заданном цвете
-- в соответвии с темой
--
local config = require('pimp3.config')
local scheme = require('pimp3.colorschemes.default')

local colors = {
  reset = scheme.color.reset
}

colors.scheme = {}
for name, col in pairs(scheme.scheme) do
  colors.scheme[name] = col
end

function colors.colorize(value, color_type)
  color_type = color_type or scheme.color.white

  if not config.has_colors then
    return tostring(value)
  end

  return color_type .. tostring(value) .. colors.reset
end

setmetatable(colors, {
  __call = colors.colorize
})

return colors
