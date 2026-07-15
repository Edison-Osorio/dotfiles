return {
  {
    "folke/twilight.nvim",
    opts = {
      dimming   = { alpha = 0.25, color = { "Normal", "#ffffff" }, term_bg = "#000000", inactive = false },
      context   = 10,
      treesitter = true,
      expand    = { "function", "method", "table", "if_statement", "for_statement", "while_statement" },
    },
    cmd  = "Twilight",
    keys = { { "<leader>zt", "<cmd>Twilight<cr>", desc = "Twilight (atenuar código)" } },
  },
  {
    "folke/zen-mode.nvim",
    dependencies = { "folke/twilight.nvim" },
    opts = {
      window = {
        backdrop = 0.95,
        width    = 120,
        height   = 1.0,
        options  = {
          signcolumn    = "no",
          number        = true,
          relativenumber = false,
          cursorline    = false,
          foldcolumn    = "0",
          list          = false,
        },
      },
      plugins = {
        options  = { enabled = true, ruler = false, showcmd = false, laststatus = 0 },
        twilight = { enabled = false },
        gitsigns = { enabled = false },
        kitty    = { enabled = false },
      },
      on_open  = function() vim.cmd("IBLToggle") end,
      on_close = function() vim.cmd("IBLToggle") end,
    },
    cmd  = "ZenMode",
    keys = { { "<leader>zz", "<cmd>ZenMode<cr>", desc = "Zen Mode (UI limpia)" } },
  },
  {
    "folke/zen-mode.nvim",
    init = function()
      vim.api.nvim_create_user_command("ZenFull", function()
        vim.cmd("ZenMode")
        vim.cmd("Twilight")
      end, {})
    end,
    keys = {
      {
        "<leader>za",
        function() vim.cmd("ZenMode"); vim.cmd("Twilight") end,
        desc = "Zen + Twilight (full focus)",
      },
    },
  },
}
