![Screenshot](https://github.com/uriid1/pimp-lua/blob/main/screenshots/pimp_logo.png)

[Russian](README.md) | English</br>
Support lua 5.1 - 5.4 and luajit

## Overview
Module for pretty-printing tables and text, as well as for simple debugging using Lua's built-in debug methods. The main goal of the module is to replace print with a more advanced tool.

![Screenshot](https://github.com/uriid1/pimp-lua/blob/main/screenshots/screenshot.png)

## Installing
```bash
luarocks install pimp
```

## Inspect Variables
```lua
p('Pimp Module!')
p(true, false, nil)
p(function() end)
p(io.stderr)
p(10000, math.pi)
p(0/0, -1/0, 1/0)

local test = function () end
p(function() end, test)

local co = coroutine.create(function() end)
p(co)

if box then
  p(box.NULL)
end
```

## Inspect Tables
```lua
local table_name = p({
  name = "John",
  age = 30,
  city = "New York"
})
```

## Inspect Functions
```lua
local function sum(a, b)
  p(a, b)
  return a + b
end

local result_sum = p(sum(10, 5))
```

**Disable or Enable output**
```lua
p:disable()
p('Hello')
p:enable()

p('World')
```

**Change prefix**
```lua
p:setPrefix({ prefix = 'INFO', sep = '|-> ' })
p('Wow! It\'s new prefix!')
p:resetPrefix()
```
```
INFO|-> file.lua:2: "Wow! It's new prefix!"
```

Extensive configuration </br>
```lua
p:resetPrefix()
p:disable()
p:enable()
p:globalDisable()
p:matchPath(str)
p:disableFullPath()
p:enableFullPath()
p:disableColor()
p:enableColor()
p:enableVisibility()
p:disableVisibility()
p:enableType()
p:disableType()
p:enableTableAddr()
p:disableTableAddr()
p:enableFullCallStack()
p:disableFullCallStack()
p:enableEscapeNonAscii()
p:disableEscapeNonAscii()
p:decimalToHexadecimal()
p.pp(t) -- Dump a table and return the dump as text
p.ppnc(t) -- Same, but without colors
p.msg(text) -- Print a text message with a timestamp
p.getLocalEnv(level) -- Return local variables at the given stack level
p:enableFindLocalName()
p:disableFindLocalName()

-- Enable/Disable resolving argument names from the call-site source line
-- p(foo) --> foo = 42; p(foo + 1) --> foo + 1 = 43
-- Requires the source file to be readable at runtime; disabled by default
p:enableFindNameFromSource()
p:disableFindNameFromSource()

-- Output limits in nodejs style (0 - unlimited)
-- Maximum table elements to display (default 100, like maxArrayLength)
p:setMaxElements(100)
-- Maximum string bytes to display (default 10000, like maxStringLength)
p:setMaxStringLength(10000)
p:enableCallStackLadder()
p:disableCallStackLadder()
```
