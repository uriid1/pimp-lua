![Screenshot](https://github.com/uriid1/pimp-lua/blob/main/screenshots/pimp_logo.png)

[Russian](README.md) | English

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
INFO|-> file.lua:2: 'Wow! It's new preffix!': [length 22]
```

**logging**
```lua
p.log.trace('Trace message')
p.log.debug('Debug message')
p.log.info('Info message')
p.log.warn('Warn message')
p.log.error('Error message')
p.log.fatal('Fatal message')
```

Extensive configuration </br>
```lua
p:resetPrefix()
p:disable()
p:enable()
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
p:enableFullFunctionsStack()
p:disableFullFunctionsStack()
p.pp(t)
```
