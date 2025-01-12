local config = require('pimp.config')

local function makePath(info)
  local filename = info and info.short_src or ''

  if config.pimp.full_path == false then
    filename = filename:match('.+/(.-)$')
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
