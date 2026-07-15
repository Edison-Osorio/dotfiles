return {
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "LazyFile",
    main = "ibl",
    opts = {
      indent = { char = "", smart_indent_cap = true },
      scope = {
        enabled    = true,
        char       = "⋮",
        show_start = true,
        show_end   = true,
        highlight  = "IblScope",
        priority   = 1000,
      },
      exclude = {
        buftypes  = { "terminal", "nofile", "quickfix", "prompt" },
        filetypes = {
          "lspinfo", "packer", "checkhealth", "help", "man",
          "gitcommit", "TelescopePrompt", "TelescopeResults",
          "Trouble", "aerial", "alpha", "dashboard",
        },
      },
    },
  },
}
