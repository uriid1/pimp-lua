--- Text colorization module.
local config = require('pimp.config')
local colorscheme = require('pimp.colorscheme.default')

local color = {}

-- Import of colors and scheme from the color theme
for name, col in pairs(colorscheme.color) do
  color[name] = col
end

color.scheme = {}
for name, col in pairs(colorscheme.scheme) do
  color.scheme[name] = col
end

--- Enable or disable colored output.
-- @tparam boolean value Color usage flag
function color.colorise(value)
  config.color.use_color = value and true or false
end

--- Wrap a value into color codes.
-- @tparam ?string colorType Color code from the scheme, white by default
-- @tparam any value Value to colorize
-- @treturn string Colorized string, or a plain one when color is disabled
function color:tocolor(colorType, value)
  colorType = colorType or self.white

  if config.color.use_color == false then
    return tostring(value)
  end

  return colorType .. tostring(value) .. color.reset
end

setmetatable(color, { __call = color.tocolor })

return color
