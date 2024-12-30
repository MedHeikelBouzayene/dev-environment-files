-- Put this file in your ~/.config/nvim/lua directory
return {
  theme_picker = function()
    local themes = {
      "tokyonight",
      "gruvbox",
      "dracula",
      "solarized",
      "catppuccin",
      "nord",
      "nightfox",
      "papercolor",
      "tender",
      "moonfly",
    }

    local set_colorscheme = function(theme)
      require("heikel.save_theme").save_theme(theme)
      vim.cmd("colorscheme " .. theme)
    end

    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    pickers
      .new({}, {
        prompt_title = "Select Theme",
        finder = finders.new_table({
          results = themes,
          entry_maker = function(entry)
            return {
              value = entry,
              display = entry,
              ordinal = entry,
            }
          end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
          local function set_theme()
            local selection = action_state.get_selected_entry()
            set_colorscheme(selection.value)
          end

          map("i", "<CR>", function()
            set_theme()
            actions.close(prompt_bufnr)
          end)

          map("i", "<C-j>", function()
            actions.move_selection_next(prompt_bufnr)
            set_theme()
          end)

          map("i", "<C-k>", function()
            actions.move_selection_previous(prompt_bufnr)
            set_theme()
          end)

          return true
        end,
      })
      :find()
  end,
}
