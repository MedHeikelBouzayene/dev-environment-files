return {
  {
    "mrcjkb/rustaceanvim",
    version = "^5", -- Recommended
    lazy = false, -- This plugin is already lazy
    ft = "rust",
    config = function()
      local mason_registry = require("mason-registry")
      local codelldb = mason_registry.get_package("codelldb")
      local extension_path = codelldb:get_install_path() .. "/extension/"
      local codelldb_path = extension_path .. "adapter/codelldb"
      local liblldb_path = extension_path .. "lldb/lib/liblldb.dylib"
      -- If you are on Linux, replace the line above with the line below:
      -- local liblldb_path = extension_path .. "lldb/lib/liblldb.so"
      local cfg = require("rustaceanvim.config")
      local bufnr = vim.api.nvim_get_current_buf()
      vim.keymap.set("n", "<leader>a", function()
        vim.cmd.RustLsp("codeAction") -- supports rust-analyzer's grouping
        -- or vim.lsp.buf.codeAction() if you don't want grouping.
      end, { silent = true, buffer = bufnr })
      vim.keymap.set(
        "n",
        "K", -- Override Neovim's built-in hover keymap with rustaceanvim's hover actions
        function()
          vim.cmd.RustLsp({ "hover", "actions" })
        end,
        { silent = true, buffer = bufnr }
      )

      vim.g.rustaceanvim = {
        server = {
          default_settings = {
            ["rust-analyzer"] = {
              imports = {
                granularity = {
                  group = "module",
                },
                prefix = "self",
              },
              cargo = {
                buildScripts = {
                  enable = true,
                },
              },
              check = {
                allTargets = true,
              },
              procMacro = {
                enable = true,
              },
              checkOnSave = {
                command = "clippy",
              },
            },
          },
          cmd = function()
            if mason_registry.is_installed("rust-analyzer") then
              local ra = mason_registry.get_package("rust-analyzer")
              local ra_filename = ra:get_receipt():get().links.bin["rust-analyzer"]
              return { ("%s/%s"):format(ra:get_install_path(), ra_filename) }
            else
              -- global installation
              return { "rust-analyzer" }
            end
          end,
        },
        dap = {
          adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path),
        },
      }
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      local dapui = require("dapui")
      dapui.setup()

      local dap = require("dap")
      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end
    end,
  },
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")
      local keymap = vim.keymap -- for conciseness
      local opts = { noremap = true, silent = true }
      -- DAP adapters configuration
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = "codelldb",
          args = { "--port", "${port}" },
        },
      }

      dap.configurations.rust = {
        {
          name = "Launch",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input(
              "Path to executable: ",
              vim.fn.getcwd() .. "/target/aarch64-apple-darwin/debug/",
              "file"
            )
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          args = {},
          runInTerminal = false,
        },
        {
          name = "Debug Tests",
          type = "codelldb",
          request = "launch",
          program = function()
            local test_binary =
              vim.fn.input("Path to test executable: ", vim.fn.getcwd() .. "/target/debug/deps/", "file")
            return test_binary
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          args = { "--nocapture" },
          runInTerminal = false,
        },
      }

      -- set keybinds
      opts.desc = "Debugger step into"
      keymap.set("n", "<leader>dl", dap.step_into, opts)

      opts.desc = "Debugger step over"
      keymap.set("n", "<leader>dj", dap.step_over, opts)

      opts.desc = "Debugger step out"
      keymap.set("n", "<leader>dk", dap.step_out, opts)

      opts.desc = "Debugger continue"
      keymap.set("n", "<leader>dc", dap.continue, opts)

      opts.desc = "Debugger toggle breakpoint"
      keymap.set("n", "<leader>db", dap.toggle_breakpoint, opts)
      opts.desc = "Debugger set conditional breakpoint"
      keymap.set(
        "n",
        "<Leader>ds",
        "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
        opts
      )
      opts.desc = "Debugger reset"
      keymap.set("n", "<Leader>de", "<cmd>lua require'dap'.terminate()<CR>", opts)
      opts.desc = "Debugger run last"
      keymap.set("n", "<Leader>dr", "<cmd>lua require'dap'.run_last()<CR>", opts)

      -- rustaceanvim
      opts.desc = "Debugger testables"
      keymap.set("n", "<Leader>dt", "<cmd>lua vim.cmd('RustLsp testables')<CR>", opts)
    end,
  },
  {
    "saecki/crates.nvim",
    tag = "stable",
    config = function()
      require("crates").setup({
        completion = {
          cmp = {
            enabled = true,
          },
        },
      })
    end,
  },
}
