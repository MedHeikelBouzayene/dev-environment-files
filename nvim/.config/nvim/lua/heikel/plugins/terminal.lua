return {
  {
    {
      "akinsho/toggleterm.nvim",
      version = "*",
      config = function()
        local keymap = vim.keymap
        local opts = { noremap = true, silent = true, desc = "Open floating terminal" }
        require("toggleterm").setup({
          float_opts = {
            border = "double",
            winblend = 20, -- Adjust this value to increase transparency (0-100)
            title_pos = "center",
          },
          keymap.set("n", "<Leader>tt", ":ToggleTerm size=40 direction=float name=build<CR>", opts),
          vim.api.nvim_create_autocmd("TermOpen", {
            pattern = "term://*",
            callback = function()
              vim.cmd("startinsert")
              vim.api.nvim_buf_set_keymap(0, "t", "<C-q>", [[<C-\><C-n>:q<CR>]], { noremap = true, silent = true })
            end,
          }),
        })
      end,
    },
  },
}
