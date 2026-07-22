--- Standard output writer.

--- Write arguments as a single line with a trailing newline and flush.
-- Empty strings are rendered as ''.
-- @tparam any ... Data to write
local function write(...)
  local args = {}
  local argsCount = select('#', ...)

  for i = 1, argsCount do
    local arg = select(i, ...)
    if arg == '' then
      arg = '\'\''
    end

    args[i] = tostring(arg)
  end

  io.write(table.concat(args, '\t'), '\n')
  io.flush()
end

return write
