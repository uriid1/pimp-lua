![Screenshot](https://github.com/uriid1/pimp-lua/blob/main/screenshots/pimp_logo.png)

[Russian](README.md) | English</br>
Support lua 5.1 - 5.4 and luajit

## Pimp
The module is intended for pretty-printing of all lua types, especially tables.</br>
It also serves for simple debugging using the built-in lua debug library.</br>
The main goal of the module is to replace print with a more advanced tool.</br>

![Screenshot](https://github.com/uriid1/pimp-lua/blob/main/screenshots/screenshot.png)

## Installing
```bash
luarocks install pimp
```

## Lua peculiarities and module performance
1. Lua has no simple way to get the name of a variable from the state.
That is why variable names literally have to be searched by value or by address.
For tables, coroutines, functions and userdata finding the name is usually not a problem, since these types have an address. Local variables are much harder: getting a name by value is possible, but when there are upvalues or locals holding the same value, there is no guarantee that a particular name corresponds to a particular value. That is why local variable name lookup is disabled by default, but you can enable this mode with the `pimp:enableFindLocalName()` method.

There is also an exact way: take the name not by value, but from the call-site source line. The mode is enabled with the `pimp:enableFindNameFromSource()` method (disabled by default):
```lua
local foo = 42
p(foo)            --> foo = 42
p(foo + 1)        --> foo + 1 = 43
p(math.floor(foo / 2)) --> math.floor(foo / 2) = 21
```
Limitations: the source file must be readable at runtime (does not work in the REPL or from bytecode)

The call must fit on a single line

With two `p()` calls on one line the names are not resolved. In all these cases the module simply falls back to the regular behavior.

2. The module is intended for testing and debugging, it slows your program down significantly, so use it for its purpose. To avoid removing module calls from the code every time, pimp can be switched off with `pimp:disable()` and back on with `pimp:enable()`. Or disabled globally with `pimp:globalDisable()`.

## Recommended way to load the module
```lua
-- Somewhere at the project entry point
_G.p = require('pimp')

-- On Windows it is better to disable colors
p:disableColor()
```

## Inspect lua types
```lua
p('Pimp Module!')
p("^([a-z0-9]+)@([%w%d]+)$")
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

## Inspect tables
```lua
-- The table is printed and
-- the table_name variable receives a reference to the table
local table_name = p({
  name = "John",
  age = 30,
  city = "New York"
})
```

## Inspect functions
```lua
local function sum(a, b)
  p(a, b)
  return a + b
end

-- The result_sum variable receives the number 15
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

All configuration methods </br>
```lua
-- Restore the default prefix
p:resetPrefix()

-- Enable/Disable the module output
-- pimp still returns every value passed into it
p:disable()
p:enable()

-- Disable the pimp output globally,
-- ignoring the p:enable() / p:disable() methods
p:globalDisable()

-- Set the path capture pattern
-- example re_str = "foo%-bar/(.+)"
p:matchPath(re_str)

-- Enable/Disable full path display
p:disableFullPath()
p:enableFullPath()

-- Enable/Disable colored output
p:disableColor()
p:enableColor()

-- Enable/Disable the local, global, method, upvalue labels
p:enableVisibility()
p:disableVisibility()

-- Enable/Disable type labels
p:enableType()
p:disableType()

-- Enable/Disable table address display
p:enableTableAddr()
p:disableTableAddr()

-- Enable/Disable display of all functions the pimp call was made from
p:enableFullCallStack()
p:disableFullCallStack()

-- Enable/Disable ladder-style call stack rendering
p:enableCallStackLadder()
p:disableCallStackLadder()

-- (Experimental) Enable/Disable local variable name lookup
p:enableFindLocalName()
p:disableFindLocalName()

-- Enable/Disable argument name resolution from the call-site source line
p:enableFindNameFromSource()
p:disableFindNameFromSource()

-- Output limits in nodejs style (0 - unlimited)
-- Maximum table elements to display (default 100, like maxArrayLength)
p:setMaxElements(100)
-- Maximum string bytes to display (default 10000, like maxStringLength)
p:setMaxStringLength(10000)

-- Enable/Disable escaping of non-ASCII characters
p:enableEscapeNonAscii()
p:disableEscapeNonAscii()

-- Display integers as hex
p:decimalToHexadecimal()

-- Dump a table and return the dump as text
p.pp(t)

-- Same, but without colors
p.ppnc(t)

-- Print a text message with a timestamp
p.msg(text)

-- Return a table of local variables at the given stack level
p.getLocalEnv(level)
```
