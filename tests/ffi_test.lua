local p = require('pimp')
:enableType()
:enableTableAddr()
:enableVisibility()
:enableFindLocalName()

local ffi = require('ffi')
local arr = ffi.new('int[5]')
p(arr)

local null = ffi.new('void*')
p(null)

local num1 = 10ULL
local num2 = 10LL
local num3 = 2^64 - 1
local num4 = 0xFFFULL
local num5 = 12.56i
p(num1)
p(num2)
p(num3)
p(num4)
p(num5)
