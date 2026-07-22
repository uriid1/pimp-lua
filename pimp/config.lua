--- Module configuration.

--- Detect terminal color support by the TERM environment variable.
-- @treturn boolean useColor
local function detectUseColor()
  local term = os.getenv('TERM')

  if term and (term == 'xterm' or term:find('-256color$')) then
    return true
  end

  return false
end

local config = {
  -- Main output options
  pimp = {
    prefix = 'p', -- Prefix of every output line
    separator = ' ➜ ', -- Separator between the prefix and the call position
    -- max_seen - safety limit on entries count:
    -- for variable lookup, stack traversal and table printing
    max_seen = 10000,
    output = true, -- Output flag, controlled by :disable / :enable
    global_disable = false, -- Global output shutdown
    full_path = true, -- Use full file paths
    match_path = '', -- Trim the full path by the given lua pattern
    show_visibility = false, -- local / global label next to values
    show_type = false, -- Type labels next to values
    show_table_addr = false, -- Table addresses
    show_full_call_stack = true, -- Full call stack
    show_call_stack_ladder = true, -- Ladder-style call stack rendering
    decimal_to_hexadecimal = false, -- Render numbers as hex
    -- find_local_name - lookup of local variable names by value.
    -- The flag does not guarantee that a found name matches the value:
      -- varargs cannot be matched to a local variable name.
      -- locals and upvalues holding equal values are indistinguishable.
    find_local_name = false,
    -- find_name_from_source - resolve argument names from the call-site
    -- source line: p(foo) -> foo = 42.
    -- Unlike find_local_name it yields exact names (and whole expressions),
    -- but requires the source file to be readable at runtime.
    find_name_from_source = false,
  },

  -- Table pretty-print options
  pretty_print = {
    tab_char = ' ', -- Indentation character
    show_type = true, -- Type labels
    show_table_addr = false, -- Table addresses
    -- max_elements - maximum table elements in the output,
    -- like maxArrayLength in nodejs (0 - unlimited)
    max_elements = 100,
  },

  -- String formatting options
  string_format = {
    escape_controls = true, -- Escape control characters
    escape_non_ascii = false, -- Escape all non-ASCII characters
    escape_colorize = true, -- Colorize escaped characters
    patterns_colorize = true, -- Colorize lua patterns
    -- max_length - maximum string bytes in the output,
    -- like maxStringLength in nodejs (0 - unlimited)
    max_length = 10000,
  },

  -- Color theme usage
  color = {
    use_color = detectUseColor(),
  },
}

return config
