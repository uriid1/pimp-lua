---
-- Writes the given arguments to the standard output stream, followed by a newline
-- character, and flushes the output
--
-- @function write
-- @param ... - The data to be written to the output
--
-- @usage
-- write("Hello, world!")
--
local function write(...)
  local data = ''
  local argsCount = select('#', ...)

  for i = 1, argsCount do
    local arg = select(i, ...)
    if arg == '' then
      arg = '\'\''
    end

    data = data..tostring(arg)..'\t'
  end

  io.write(data, '\n')
  io.flush()
end

return write
