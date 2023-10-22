# Pimp Module

## Overview

The Pimp Module is a Lua module designed to aid in debugging and logging by providing functions to print and format information about function calls, arguments, and more. It offers a simple way to enhance the debugging process in your Lua applications.

## Features

- Display information about function calls, including function names, line numbers, and arguments.
- Automatically pretty-print Lua tables.
- Format and display various data types, including tables, numbers, functions, strings, threads, booleans, and more.
- Customize output with colorization. (IN DEV)

## Usage
**Debug Function**

The core functionality of the module is the debug function. You can use it to print and format debugging information. Here's an example of how to use it:

```lua
local p = require 'pimp'
p("This is a debugging message", 42, { key = "value" }, true)
```
This will print information about the function call, its arguments, and format the arguments accordingly.
Pretty-Printing Tables

The module can automatically pretty-print tables when passed as arguments to the debug function. This makes it easier to inspect table contents.

```lua
local t = { name = "John", age = 30, city = "New York" }
p(t)
```

*See test.lua for more examples