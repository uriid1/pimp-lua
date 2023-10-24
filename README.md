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
local function sum(a, b)
  return a + b
end

p(sum(10, 5))
```
```bash
p| file.lua:5: sum(10, 5) return: 15: [number]
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
```bash
p| test.lua:1: {
  age = 30: [number],
  name = 'John': [length 4],
  city = 'New York': [length 8],
}
```

**Inspect Functions**
```lua
local function sum(a, b)
  p(a, b)
  return a + b
end

p(sum(10, 5))
```
```bash
p| file.lua:5: in sum(a, b): 10: [number], 5: [number]
p| file.lua:6: sum(10, 5) return: 15: [number]
```

**Disable or Enable output**
```lua
p:disable()
p('Hello')
p:enable()

p('World')
```
```bash
p| file.lua:6: 'World': [length 5]
```

**Change prefix**
```lua
p:setPrefix('Test')
p('Wow! It\'s new prefix!')
p:setPrefix('p')
```
```bash
Test| file.lua:2: 'Wow! It's new preffix!': [length 22]
```

*See test.lua for more examples
