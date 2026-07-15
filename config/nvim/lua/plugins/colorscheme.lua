return {
  {
    "catppuccin/nvim",
    name     = "catppuccin",
    priority = 1000,
    opts = {
      flavour           = "macchiato",
      background        = { light = "latte", dark = "macchiato" },
      transparent_background = false,
      show_end_of_buffer     = false,
      term_colors            = true,
      dim_inactive           = { enabled = false },

      styles = {
        comments     = { "italic" },
        conditionals = { "italic" },
        functions    = {},
        keywords     = { "italic" },
        strings      = {},
        variables    = {},
      },

      integrations = {
        cmp                = true,
        gitsigns           = true,
        neo_tree           = true,
        telescope          = { enabled = true, style = "nvchad" },
        treesitter         = true,
        treesitter_context = true,
        mason              = true,
        which_key          = true,
        lsp_trouble        = true,
        noice              = true,
        notify             = true,
        mini               = { enabled = true, indentscope_color = "" },
        indent_blankline   = { enabled = true, scope_color = "lavender", colored_indent_levels = false },
        dashboard          = true,
        bufferline         = false,
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors      = { "italic" },
            hints       = { "italic" },
            warnings    = { "italic" },
            information = { "italic" },
          },
          underlines = {
            errors      = { "undercurl" },
            hints       = { "undercurl" },
            warnings    = { "undercurl" },
            information = { "undercurl" },
          },
          inlay_hints = { background = true },
        },
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "catppuccin" },
  },
}
