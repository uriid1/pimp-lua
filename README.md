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
p('Hello, World!')
p(10000, math.pi)
p(true, false)
p(0/0, -1/0, 1/0)
p(function() end)
p(coroutine.create(function() end))
p(io.stderr)
```
```
p|> test.lua:1: 'Hello, World!': [length 13]
p|> test.lua:2: 10000: [number], 3.1415926535898: [number]
p|> test.lua:3: true: [boolean], false: [boolean]
p|> test.lua:4: nan: [number], -inf: [number], inf: [number]
p|> test.lua:5: function() end return: function: 0x7f306c7f9a18
p|> test.lua:6: coroutine.create(function() end) return: thread: 0x7f306c800ec0
p|> test.lua:6: file (0x7f306c73d4e0): [userdata]
```

**Inspect Tables**
```lua
local t = {
  name = "John",
  age = 30,
  city = "New York"
}

p(t)
```
```
p|> test.lua:1: {
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
p|> file.lua:6: sum(10, 5) return: 15: [number]
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

**Limitations**
*Avoid lines like:*
```lua
my_func( p(param_1), p(param_2), p(param_3) )
```
This is because the result of the capture will be param_3. Since the Lua debug module only reports the line number where the function was called and does not provide the function's position.

*See test.lua for more examples
