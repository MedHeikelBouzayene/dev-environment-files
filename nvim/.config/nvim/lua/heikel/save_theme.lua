return {
  save_theme = function(theme)
    local theme_file = vim.fn.stdpath("config") .. "/theme.txt"
    local file = io.open(theme_file, "w")
    if file then
      file:write(theme)
      file:close()
    end
  end,
}
