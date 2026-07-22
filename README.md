![Screenshot](https://github.com/uriid1/pimp-lua/blob/main/screenshots/pimp_logo.png)

Russian | [English](README_EN.md)</br>
На текущий момент, наиболее полная документация доступна только на русском языке.</br>
Поддерживаются версии lua 5.1 - 5.4 и luajit

## Pimp
Модуль предназначен для красивой печати всех lua-типов, в особенности таблиц.</br>
А так же служит для простой отладки с использованием встроенной lua библиотеки debug.</br>
Основная цель модуля — заменить print более совершенным инструментом.</br>

![Screenshot](https://github.com/uriid1/pimp-lua/blob/main/screenshots/screenshot.png)

## Установка
```bash
luarocks install pimp
```

## Особенности lua и скорость работы модуля
1. В lua нет возможности получить простым путем имя какой-либо переменной из стейта.
Поэтому имена переменных, приходится буквально искать по значению или адресу.
В случае с таблицами, coroutine, функциями и userdata чаще всего нет проблем найти имя переменной, так как у этих типов есть адрес. С локальными переменными всё намного сложнее, получить имя по значению можно, но если будут upvalue или в локальном стеке переменные с таким же значением, нельзя гарантировать, что конкретное имя переменной будет соответствует конкретному значению. Поэтому по умолчанию в модуле отключен поиск имён локальных переменных, но вы можете включить этот режим, используя метод - `pimp:enableFindLocalName()`

Есть и точный способ: брать имя не по значению, а из исходной строки вызова. Режим включается методом `pimp:enableFindNameFromSource()` (по умолчанию выключен):
```lua
local foo = 42
p(foo)            --> foo = 42
p(foo + 1)        --> foo + 1 = 43
p(math.floor(foo / 2)) --> math.floor(foo / 2) = 21
```
Ограничения: нужен доступ к файлу с исходником в рантайме (не работает в REPL и из байткода)

Ввызов должен умещаться на одной строке

При двух вызовах `p()` на одной строке имена не определяются. Во всех этих случаях модуль просто откатывается к обычному поведению.

2. Модуль предназначен для тестирования и отладки кода, он значительно замедляет вашу программу, поэтому используйте его по назначению. А что бы не пришлось каждый раз удалять методы модуля из кода, существует возможность отключить работу pimp - `pimp:disable()`. И так же включить - `pimp:enable()`. Либо же отключить глобально - `pimp:globalDisable()`.

## Рекомендация по загрузке модуля
```lua
-- Где-нибудь в точке входа в проект
_G.p = require('pimp')

-- При использовании Windows, лучше отключить отображение цветов
p:disableColor()
```

## Инспектирование lua-типов
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

## Инспектирование таблиц
```lua
-- Таблица будет распечатана
-- переменной table_name присвоиться ссылка на таблицу
local table_name = p({
  name = "John",
  age = 30,
  city = "New York"
})
```

## Инспектирование функций
```lua
local function sum(a, b)
  p(a, b)
  return a + b
end

-- В переменной result_sum будет число 15
local result_sum = p(sum(10, 5))
```

**Включение и отключение вывода*
```lua
p:disable()
p('Hello')
p:enable()

p('World')
```

**Смена префикса**
```lua
p:setPrefix({ prefix = 'INFO', sep = '|-> ' })
p('Wow! It\'s new prefix!')
p:resetPrefix()
```
```
INFO|-> file.lua:2: "Wow! It's new prefix!"
```

Все методы для настройки </br>
```lua
-- Возвращает префикс по умолчанию
p:resetPrefix()

-- Вкл/Выкл работы модуля
-- при этом pimp возвращает все методы, которые в него попадают
p:disable()
p:enable()

-- Глобальное отключение вывода из pimp
-- игнорируя методы p:enable() / p:disable()
p:globalDisable()

-- Установка паттерна на захват пути
-- пример re_str = "foo%-bar/(.+)"
p:matchPath(re_str)

-- Вкл/Выкл отображение полных путей
p:disableFullPath()
p:enableFullPath()

-- Вкл/Выкл отображение цветов
p:disableColor()
p:enableColor()

-- Вкл/Выкл отображения local, global, method, upvalue
p:enableVisibility()
p:disableVisibility()

-- Вкл/Выкл отображения типов
p:enableType()
p:disableType()

-- Вкл/Выкл отображения адресов таблиц
p:enableTableAddr()
p:disableTableAddr()

-- Вкл/Выкл отображения всех функций, из которых был вызов pimp-а
p:enableFullCallStack()
p:disableFullCallStack()

-- Вкл/Выкл стека функций в виде лесенки
p:enableCallStackLadder()
p:disableCallStackLadder()

-- (Экспериментально) Вкл/Выкл поиска имени локальной переменной
p:enableFindLocalName()
p:disableFindLocalName()

-- Вкл/Выкл определения имён аргументов по исходной строке вызова
p:enableFindNameFromSource()
p:disableFindNameFromSource()

-- Лимиты вывода в стиле nodejs (0 - без ограничения)
-- Максимум элементов таблицы (по умолчанию 100, как maxArrayLength)
p:setMaxElements(100)
-- Максимум байт строки (по умолчанию 10000, как maxStringLength)
p:setMaxStringLength(10000)

-- Вкл/Выкл экранирования не ASCII символов
p:enableEscapeNonAscii()
p:disableEscapeNonAscii()

-- Отображение целых чисел в hex-виде
p:decimalToHexadecimal()

-- Метод сдампит таблицу и вернет дамп текстом
p.pp(t)

-- То же самое, но без цветов
p.ppnc(t)

-- Печать текстового сообщения с таймстампом
p.msg(text)

-- Метод вернет таблицей локальные переменные по заданному уровню
p.getLocalEnv(level)
```
