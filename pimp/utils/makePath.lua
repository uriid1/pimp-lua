local function makePath(info, args)
  local filename = info.short_src

  if args.fullPath == false then
    filename = filename:match('.+/(.-)$')
  else
    if args.matchPath ~= '' then
      local matchPath = filename:match(args.matchPath)
      if matchPath then
        filename = matchPath
      end
    end
  end

  return filename
end

return makePath
