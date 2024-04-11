local function pipe(...)
  local handlers = {...}

  return function (text)
    for _, handler in ipairs(handlers) do
      return handler(text)
    end
  end
end

return pipe
