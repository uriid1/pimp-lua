---
--
local ffi = require('ffi')

ffi.cdef[[
  typedef struct {
    unsigned short ws_row;
    unsigned short ws_col;
    unsigned short ws_xpixel;
    unsigned short ws_ypixel;
  } winsize;

  int ioctl(int fd, unsigned long request, ...);
]]

local DEFAULT_COLS = 80
local DEFAULT_ROWS = 20

-- IOCTL коды для разных ОС
local TIOCGWINSZ = {
  linux = 0x5413,
  macos = 0x40087468,
  bsd = 0x40087468,
  windows = 0x5413,
  unknown = 0x5413
}

local function getTIOCGWINSZ()
  local __os = string.lower(jit.os)
  return TIOCGWINSZ[__os] or TIOCGWINSZ.unknown
end

local term = {}

---
-- @return[1] cols
-- @return[2] rows
function term.getSize()
  local TIOCGWINSZ = getTIOCGWINSZ()
  local ws = ffi.new("winsize")

  if ffi.C.ioctl(1, TIOCGWINSZ, ws) == 0 then
    return tonumber(ws.ws_col), tonumber(ws.ws_row)
  end

  return DEFAULT_COLS, DEFAULT_ROWS
end

function term.getColorSupport()
  local term = os.getenv("TERM")

  if term == nil then
    return false
  end

  local term_str = term:lower()
  if term_str == "dumb" then
    return false
  end

  if term_str:match("256color") then
    return true
  end
end

function term.getInfo()
  local cols, rows = term.getSize()
  local has_colors = term.getColorSupport()

  return {
    cols = cols,
    rows = rows,
    has_colors = has_colors,
  }
end

return term
