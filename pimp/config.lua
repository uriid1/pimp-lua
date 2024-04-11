local config = {
  pimp = {
    output = true,
    colors = true,
    full_path = true,
    show_visibility = false,
    show_type = false,
    show_table_addr = false,
    show_full_functions_stack = true,
    match_path = '',
  },

  pretty_print = {
    tab_char = ' ',
    show_type = true,
    show_table_addr = false,
  },

  string_format = {
    escape_controls = false,
    escape_colorize = true,
  },

  log = {
    outfile = 'log.txt',
    usecolor = false,
    ignore = {},
    match_path = '',
  },

  color = {
    use_color = true,
  }
}

return config
