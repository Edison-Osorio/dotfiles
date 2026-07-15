return {
  {
    "linux-cultist/venv-selector.nvim",
    branch       = "regexp",
    dependencies = {
      "neovim/nvim-lspconfig",
      { "nvim-telescope/telescope.nvim", branch = "0.1.x" },
    },
    ft      = "python",
    cmd     = { "VenvSelect", "VenvSelectCached" },
    opts = {
      settings = {
        search = {
          venvs = { command = "fd -HI --no-ignore-vcs -t d 'python' ." },
        },
        options = {
          notify_user_on_venv_activation = true,
          set_environment_variables      = true,
          activate_venv_in_shell         = true,
          parents = 2,
        },
      },
    },
    keys = {
      { "<leader>cv", "<cmd>VenvSelect<cr>",       desc = "Select VirtualEnv",     ft = "python" },
      { "<leader>cV", "<cmd>VenvSelectCached<cr>", desc = "Reuse last VirtualEnv", ft = "python" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode          = "basic",
                autoImportCompletions     = true,
                autoSearchPaths           = true,
                useLibraryCodeForTypes    = true,
                diagnosticMode            = "workspace",
                reportMissingModuleSource = "none",
              },
            },
          },
        },
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode       = "basic",
                autoImportCompletions  = true,
                autoSearchPaths        = true,
                useLibraryCodeForTypes = true,
                diagnosticMode         = "workspace",
              },
            },
          },
        },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft["htmldjango"] = { "djlint" }
      return opts
    end,
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft["htmldjango"] = { "djlint" }
      opts.formatters_by_ft["python"]     = { "ruff_format", "ruff_organize_imports" }
      return opts
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "pyright", "basedpyright", "ruff", "djlint", "black", "isort",
      })
    end,
  },
}
