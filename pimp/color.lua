local color = {
  use_color = true,

  reset ="\27[0m",

  black = "\27[38;5;0m",
  red = "\27[38;5;1m",
  green = "\27[38;5;2m",
  yellow = "\27[38;5;3m",
  blue = "\27[38;5;4m",
  magenta = "\27[38;5;5m",
  cyan = "\27[38;5;6m",
  orange = "\27[38;5;208m",
  purple = "\27[38;5;165m",
  gray = "\27[38;5;232m",
  white = "\27[38;5;7m",
  gold = "\27[38;5;220m",

  lightGreen = "\27[38;5;85m",
  lightYellow = "\27[38;5;226m",

  brightBlack = "\27[38;5;8m",
  brightRed = "\27[38;5;9m",
  brightGreen = "\27[38;5;10m",
  brightYellow = "\27[38;5;11m",
  brightBlue = "\27[38;5;12m",
  brightMagenta = "\27[38;5;13m",
  brightCyan = "\27[38;5;14m",
  brightOrange = "\27[38;5;202m",
  brightWhite = "\27[38;5;15m",

  darkRed = "\27[38;5;124m",
  darkGreen = "\27[38;5;28m",
  darkYellow = "\27[38;5;58m",
  darkBlue = "\27[38;5;19m",
  darkMagenta = "\27[38;5;127m",
  darkCyan = "\27[38;5;31m",
  darkWhite = "\27[38;5;15m",
}

color.scheme = {
  Boolean = color.brightMagenta,
  Cdata = color.brightBlue,
  Function = color.brightRed,
  Nil = color.red,
  Number = color.lightGreen,
  String = color.gold,
  Table = color.white,
  Thread = color.brightBlue,
  Userdata = color.brightBlue,
  Unknown = color.red,

  metatable = color.brightCyan,
  cycleTable = color.red,
  address = color.red,
  debugAddress = color.brightYellow,

  tableBrackets = color.whiite,
  emtyTable = color.white,
  tableField = color.yellow,

  visibility = color.blue,

  controls = color.magenta,

  error = color.red,
}

function color:colorise(value)
  self.use_color = value and true or false
end

function color:tocolor(color_type, value)
  color_type = color_type or self.white

  if self.use_color == false then
    return tostring(value)
  end

  return color_type..tostring(value)..color.reset
end

setmetatable(color, { __call = color.tocolor })

return color
