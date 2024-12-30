return {
  load_saved_theme = function()
    local theme_file = vim.fn.stdpath("config") .. "/theme.txt"
    local file = io.open(theme_file, "r")
    if file then
      local theme = file:read("*line")
      file:close()
      if theme then
        vim.cmd("colorscheme " .. theme)
      end
    end
  end,
}
