local util = require("lspconfig.util")

local function get_typescript_lib(root_dir)
  local local_ts = util.path.join(root_dir, "node_modules", "typescript", "lib")
  if vim.fn.isdirectory(local_ts) == 1 then return local_ts end
  return vim.fn.stdpath("data") .. "/mason/packages/typescript-language-server/node_modules/typescript/lib"
end

local function get_angular_probe(root_dir)
  local local_ng = util.path.join(root_dir, "node_modules")
  if vim.fn.isdirectory(local_ng) == 1 then return local_ng end
  return vim.fn.stdpath("data") .. "/mason/packages/angular-language-server/node_modules"
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ts_ls = {
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints                        = "literals",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints                = true,
                includeInlayVariableTypeHints                         = false,
                includeInlayPropertyDeclarationTypeHints              = true,
                includeInlayFunctionLikeReturnTypeHints               = true,
                includeInlayEnumMemberValueHints                      = true,
              },
              preferences = { importModuleSpecifier = "relative" },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints          = "literals",
                includeInlayFunctionParameterTypeHints  = true,
                includeInlayVariableTypeHints           = false,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints        = true,
              },
            },
          },
        },
        angularls = {
          root_dir  = util.root_pattern("angular.json", "project.json", ".git"),
          filetypes = { "typescript", "html", "typescriptreact" },
          on_new_config = function(new_config, new_root_dir)
            local ts_probe = get_typescript_lib(new_root_dir)
            local ng_probe = get_angular_probe(new_root_dir)
            new_config.cmd = {
              "ngserver", "--stdio",
              "--tsProbeLocations", ts_probe,
              "--ngProbeLocations",  ng_probe,
            }
          end,
        },
      },
      setup = {
        angularls = function(_, opts)
          require("lspconfig").angularls.setup(opts)
          return true
        end,
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "typescript", "tsx", "javascript", "html", "css", "scss", "json", "graphql",
      })
      return opts
    end,
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      for _, ft in ipairs({
        "typescript", "typescriptreact", "javascript", "javascriptreact",
        "html", "css", "scss", "less", "json", "jsonc", "yaml", "graphql", "markdown",
      }) do
        opts.formatters_by_ft[ft] = { "prettier" }
      end
      opts.formatters = opts.formatters or {}
      opts.formatters.prettier = {
        require_cwd = false,
        condition = function(_, ctx)
          return vim.fs.find(
            { ".prettierrc", ".prettierrc.js", ".prettierrc.json", "prettier.config.js" },
            { path = ctx.filename, upward = true }
          )[1] ~= nil
        end,
      }
      return opts
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "typescript-language-server", "angular-language-server",
        "eslint-lsp", "prettier", "css-lsp", "html-lsp",
        "json-lsp", "tailwindcss-language-server",
      })
    end,
  },
}
