--- File path builder from debug info.
local config = require('pimp.config')

--- Build the file path respecting full_path and match_path options.
-- @tparam table info Result of debug.getinfo with the short_src field
-- @treturn string filename
local function makePath(info)
  local filename = info and info.short_src or ''

  if config.pimp.full_path == false then
    -- Paths without a separator (stdin, a file in the cwd) are kept as is
    filename = filename:match('.+/(.-)$') or filename
  else
    if config.pimp.match_path ~= '' then
      local matchPath = filename:match(config.pimp.match_path)
      if matchPath then
        filename = matchPath
      end
    end
  end

  return filename
end

return makePath
