local function get_typescript_lib(root_dir)
  local local_ts = vim.fs.joinpath(root_dir, "node_modules", "typescript", "lib")
  if vim.fn.isdirectory(local_ts) == 1 then return local_ts end
  return vim.fn.stdpath("data") .. "/mason/packages/angular-language-server/node_modules/typescript/lib"
end

local function get_angular_probe(root_dir)
  local local_ng = vim.fs.joinpath(root_dir, "node_modules")
  if vim.fn.isdirectory(local_ng) == 1 then return local_ng end
  return vim.fn.stdpath("data") .. "/mason/packages/angular-language-server/node_modules"
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- LazyVim usa vtsls para TypeScript/JavaScript (ts_ls ya no se habilita)
        vtsls = {
          settings = {
            typescript = {
              inlayHints = {
                parameterNames            = { enabled = "literals" },
                parameterTypes            = { enabled = true },
                variableTypes             = { enabled = false },
                propertyDeclarationTypes  = { enabled = true },
                functionLikeReturnTypes   = { enabled = true },
                enumMemberValues          = { enabled = true },
              },
              preferences = { importModuleSpecifier = "relative" },
            },
            javascript = {
              inlayHints = {
                parameterNames            = { enabled = "literals" },
                parameterTypes            = { enabled = true },
                variableTypes             = { enabled = false },
                functionLikeReturnTypes   = { enabled = true },
                enumMemberValues          = { enabled = true },
              },
            },
          },
        },
        angularls = {
          -- solo en proyectos Angular/Nx (sin marcador, no arranca)
          root_dir = function(bufnr, on_dir)
            local root = vim.fs.root(bufnr, { "angular.json", "project.json" })
            if root then on_dir(root) end
          end,
          filetypes    = { "typescript", "html", "typescriptreact" },
          before_init = function(_, config)
            local root = config.root_dir or vim.uv.cwd()
            config.cmd = {
              "ngserver", "--stdio",
              "--tsProbeLocations", get_typescript_lib(root),
              "--ngProbeLocations", get_angular_probe(root),
            }
          end,
        },
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
        "vtsls", "angular-language-server",
        "eslint-lsp", "prettier", "css-lsp", "html-lsp",
        "json-lsp", "tailwindcss-language-server",
      })
    end,
  },
}
