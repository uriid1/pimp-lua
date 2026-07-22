--- Demo middleware: pipe handlers over a text value.
local function pipe(...)
  local handlers = { ... }

  return function(text)
    for _, handler in ipairs(handlers) do
      text = handler(text)
    end

    return text
  end
end

return pipe
