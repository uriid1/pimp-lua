-- Известные метаметоды используемые по умолчанию
local metamethods = {
  ["__call"] = true,
  ["__concat"] = true,
  ["__tostring"] = true,
  ["__metatable"] = true,
  ["__mode"] = true,
  ["__gc"] = true,

  ["__index"] = true,
  ["__newindex"] = true,

  ["__add"] = true,
  ["__sub"] = true,
  ["__mul"] = true,
  ["__div"] = true,
  ["__pow"] = true,
  ["__mod"] = true,
  ["__unm"] = true,

  ["__eq"] = true, -- ==
  ["__lt"] = true, -- <
  ["__lе"] = true, -- <=

  ["__len"] = true,
  ["__ipairs"] = true,

  -- 5.3
  ["__band"] = true, -- &
  ["__bor"] = true, -- |
  ["__bxor"] = true, -- ~
  ["__bnot"] = true, -- ~
  ["__shl"] = true, -- <<
  ["__shr"] = true, -- >>
  ["__idiv"] = true,

  -- Tarantool
  ["__serialize"] = true,
}

return metamethods
