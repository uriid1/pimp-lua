# Pimp Module
![Screenshot](https://github.com/uriid1/scrfmp/blob/main/pimp/pimp.png)

## Overview
The Pimp Module designed to aid in debugging and logging by providing functions to print and format information about function calls, arguments, and more. It offers a simple way to enhance the debugging process in your Lua applications.

## Features and Usage
**Debug Function**

The core functionality of the module is the debug function. You can use it to print and format debugging information:

```lua
local p = require 'pimp'
p("This is a debugging message", 42, { key = "value" }, true)
```

**Inspect Variables**
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
```
p|> file.lua:7: 'Pimp Module!': [len 12]
p|> file.lua:8: true: [boolean], false: [boolean], nil
p|> file.lua:9: <function: 0x402899e8>
p|> file.lua:10: <file (0x7f14da5f74e0)>: [userdata]
p|> file.lua:11: 10000: [number], 3.1415926535898: [number]
p|> file.lua:12: nan: [number], -inf: [number], inf: [number]
p|> file.lua:15: <function: 0x41d7a090>, test = <function: 0x411c7b70>
p|> file.lua:18: co = <thread: 0x411f8a30>
p|> file.lua:21: <cdata<void *>: NULL>: [cdata]
```

**Inspect Tables**
```lua
local table_name = {
  name = "John",
  age = 30,
  city = "New York"
}

p(t)
```
```
p|> test.lua:1: table_name = {
  age = 30: [number],
  name = 'John': [length 4],
  city = 'New York': [length 8],
}: [table]
```

**Inspect Functions**
```lua
local function sum(a, b)
  p(a, b)
  return a + b
end

local result_sum = p(sum(10, 5))
```
```
p|> file.lua:5 in sum(a: 10, b: 5) 10: [number], 5: [number]
p|> file.lua:6: 15: [number]
```

**Disable or Enable output**
```lua
p:disable()
p('Hello')
p:enable()

p('World')
```
```
p|> file.lua:6: 'World': [length 5]
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

*See test.lua for more examples
