![Screenshot](https://github.com/uriid1/pimp-lua/blob/main/screenshots/pimp_logo.png)

Russian | [English](README_EN.md)</br>
На текущий момент, наиболее полная документация доступна только на русском языке.</br>
Поддерживаются версии lua5.4 и luajit

## Pimp
Модуль предназначен для красивой печати всех lua-типов, в особенности таблиц. А так же служит для простой отладки с использованием встроенной lua библиотеки debug.
Основная цель модуля — заменить print более совершенным инструментом.</br>
Создан вдохновившись icecream в python.

![Screenshot](https://github.com/uriid1/pimp-lua/blob/main/screenshots/screenshot.png)

## Установка
```bash
luarocks install pimp
```

## Особенности lua и скорость работы модуля
1. В lua нет возможности получить простым путем имя какой-либо переменной из стейта.
Поэтому имена переменных, приходится буквально искать по значению или адресу.
В случае с таблицами, coroutine, функциями и userdata чаще всего нет проблем найти имя переменной, так как у этих типов есть адрес. С локальными переменными всё намного сложнее, получить имя по значению можно, но если будут upvalue или в локальном стеке переменные с таким же значением, нельзя гарантировать, что конкретное имя переменной будет соответствует конкретному значению. Поэтому по умолчанию в модуле отключен поиск имён локальных переменных, но вы можете включить этот режим, используя метод - `pimp:enableFindLocalName()`

2. Модуль предназначен для тестирования и отладки кода, он значительно замедляет вашу программу, поэтому используйте его по назначению. А что бы не пришлось каждый раз удалять методы модуля из кода, существует возможность отключить работу pimp - `pimp:disable()`. И так же включить - `pimp:enable()`.

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
INFO|-> file.lua:2: 'Wow! It's new preffix!': [length 22]
```

**Логирование**
```lua
--- Модуль log работает синхронно
p.log.trace('Trace message')
p.log.debug('Debug message')
p.log.info('Info message')
p.log.warn('Warn message')
p.log.error('Error message')
p.log.fatal('Fatal message')
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

-- Метод сдампит таблицу, без цветов
-- и вернет текстом дамп
p.pp(t)

-- Метод вернет таблицей локальные переменные по заданному уровню
p.getLocalEnv(level)
```
