--- Argument name resolution from the call-site source line.
--
-- p(foo, bar + 1) -> { 'foo', 'bar + 1' }
--
-- Works only when the source is available as a file (info.source starts with '@').
-- Files are cached for the process lifetime.

-- Source line cache: filename -> array of lines (false - file is unreadable)
local cache = {}

--- Read a source line by number.
-- @tparam string source The source field of debug.getinfo
-- @tparam number lineNum Line number
-- @treturn ?string line
local function readSourceLine(source, lineNum)
  if type(source) ~= 'string' or source:sub(1, 1) ~= '@' then
    return nil
  end

  local filename = source:sub(2)
  local lines = cache[filename]

  if lines == nil then
    local fd = io.open(filename, 'r')
    if fd == nil then
      cache[filename] = false
      return nil
    end

    lines = {}
    for line in fd:lines() do
      lines[#lines + 1] = line
    end
    fd:close()

    cache[filename] = lines
  end

  if lines == false then
    return nil
  end

  return lines[lineNum]
end

--- Check whether an expression is a literal.
-- Literals are not used as names: p(42) prints just 42, not "42 = 42".
-- @tparam string expr Expression text
-- @treturn boolean isLiteral
local function isLiteral(expr)
  if expr == 'true' or expr == 'false' or expr == 'nil' or expr == '...' then
    return true
  end

  -- Numbers, including hex and exponents
  if tonumber(expr) then
    return true
  end

  local firstChar = expr:sub(1, 1)
  if firstChar == '"' or firstChar == '\'' or firstChar == '{' then
    return true
  end

  if expr:match('^%[%[') or expr:match('^function%f[%W]') then
    return true
  end

  return false
end

--- Strip leading and trailing whitespace.
-- @tparam string str Input string
-- @treturn string trimmed
local function trim(str)
  return str:match('^%s*(.-)%s*$')
end

--- Split an argument list by top-level commas.
-- Commas inside brackets and strings do not split arguments.
-- @tparam string argsStr Argument text without the outer parentheses
-- @treturn table names Array of names with holes for literals
-- @treturn number count Argument count
local function splitArgs(argsStr)
  local names = {}
  local count = 0
  local depth = 0
  local quote = nil
  local start = 1
  local i = 1
  local len = #argsStr

  while i <= len do
    local char = argsStr:sub(i, i)

    if quote then
      if char == '\\' then
        i = i + 1
      elseif char == quote then
        quote = nil
      end
    elseif char == '"' or char == '\'' then
      quote = char
    elseif char == '(' or char == '{' or char == '[' then
      depth = depth + 1
    elseif char == ')' or char == '}' or char == ']' then
      depth = depth - 1
    elseif char == ',' and depth == 0 then
      count = count + 1
      local expr = trim(argsStr:sub(start, i - 1))
      if expr ~= '' and not isLiteral(expr) then
        names[count] = expr
      end
      start = i + 1
    end

    i = i + 1
  end

  local last = trim(argsStr:sub(start))
  if count > 0 or last ~= '' then
    count = count + 1
    if last ~= '' and not isLiteral(last) then
      names[count] = last
    end
  end

  return names, count
end

--- Extract argument names of the aliasName(...) call from the source.
-- Returns nil when names cannot be resolved:
  -- the source is not accessible.
  -- the call spans multiple lines.
  -- several calls share one line.
-- @tparam table info Result of debug.getinfo with source and currentline fields
-- @tparam ?string aliasName Name pimp is visible under at the call site (usually 'p')
-- @treturn[1] table names Array of names with holes for literals
-- @treturn[1] number count Argument count
-- @treturn[2] nil
local function sourceNames(info, aliasName)
  if type(aliasName) ~= 'string' or aliasName == '' then
    return nil
  end

  local line = readSourceLine(info.source, info.currentline)
  if line == nil then
    return nil
  end

  -- The name as a standalone word: p, but not pp and not my_p
  local pattern = '%f[%w_]' .. aliasName:gsub('%W', '%%%0') .. '%f[^%w_]'
  local argsStr = nil
  local searchPos = 1

  while true do
    local startPos, endPos = line:find(pattern, searchPos)
    if startPos == nil then
      break
    end

    local nextPos = line:match('^%s*()', endPos + 1)
    local nextChar = line:sub(nextPos, nextPos)

    -- Only p(...) calls matter, p.method and p:method accesses are skipped
    if nextChar == '(' then
      local callArgs = line:match('%b()', nextPos)

      if callArgs == nil then
        -- The bracket is not closed on this line - a multiline call
        return nil
      end

      if argsStr ~= nil then
        -- More than one call per line - ambiguous
        return nil
      end

      argsStr = callArgs:sub(2, -2)
    end

    searchPos = endPos + 1
  end

  if argsStr == nil then
    return nil
  end

  return splitArgs(argsStr)
end

return sourceNames
