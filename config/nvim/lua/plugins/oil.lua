return {
  -- Deshabilitar dashboard de snacks (oil lo reemplaza al arrancar)
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = { enabled = false },
    },
  },

  -- Oil: explorador de archivos como buffer, abre al arrancar sin archivo
  {
    "stevearc/oil.nvim",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      default_file_explorer = true,
      columns = { "icon" },
      view_options = {
        show_hidden = true,
      },
      float = {
        padding        = 2,
        max_width      = 80,
        max_height     = 30,
        border         = "rounded",
        win_options    = { winblend = 0 },
      },
      keymaps = {
        ["<CR>"]  = "actions.select",
        ["-"]     = "actions.parent",
        ["_"]     = "actions.open_cwd",
        ["q"]     = "actions.close",
        ["<Esc>"] = "actions.close",
        ["gs"]    = "actions.change_sort",
        ["g."]    = "actions.toggle_hidden",
        ["gp"]    = "actions.preview",
        ["gr"]    = "actions.refresh",
      },
      use_default_keymaps = false,
    },
    init = function()
      -- Abrir oil al iniciar nvim sin argumentos
      vim.api.nvim_create_autocmd("VimEnter", {
        once = true,
        callback = function()
          if vim.fn.argc() == 0 then
            require("oil").open()
          end
        end,
      })
    end,
  },
}
