-- ── A: claude-code.nvim — Claude Code CLI en ventana flotante ────────────────
-- Atajo: <leader>ac  |  no necesita API key, usa el CLI instalado
local M_claude_code = {
  "greggh/claude-code.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>ac", desc = "Claude Code (toggle)" },
    { "<leader>aA", desc = "Claude Code (nueva sesión)" },
  },
  cmd = { "ClaudeCode", "ClaudeCodeContinue" },
  opts = {
    window = {
      position    = "vertical",
      split_ratio = 0.38,
      enter_insert = true,
      hide_numbers = true,
      hide_signcolumn = true,
    },
    keymaps = {
      toggle = {
        normal   = "<leader>ac",
        terminal = "<leader>ac",
      },
      window_navigation = true,
      scrolling = true,
    },
  },
}

-- ── C: terminal flotante con Claude Code CLI ──────────────────────────────────
-- Atajo: <leader>at  |  fallback sin API key
local M_terminal = {
  "akinsho/toggleterm.nvim",
  version = "*",
  keys = {
    { "<leader>at", desc = "Claude Code (terminal flotante)" },
    { "<leader>aT", desc = "Terminal flotante" },
  },
  opts = {
    size = function(term)
      if term.direction == "horizontal" then return 18
      elseif term.direction == "vertical" then return math.floor(vim.o.columns * 0.4)
      end
    end,
    open_mapping    = nil,
    hide_numbers    = true,
    shade_terminals = false,
    start_in_insert = true,
    insert_mappings = true,
    persist_size    = true,
    direction       = "float",
    close_on_exit   = true,
    shell           = vim.o.shell,
    float_opts = {
      border   = "rounded",
      width    = math.floor(vim.o.columns * 0.85),
      height   = math.floor(vim.o.lines * 0.80),
      winblend = 3,
    },
    highlights = {
      FloatBorder = { link = "FloatBorder" },
    },
  },
  config = function(_, opts)
    require("toggleterm").setup(opts)
    local Terminal = require("toggleterm.terminal").Terminal

    local claude_term = Terminal:new({
      cmd       = "claude",
      direction = "float",
      hidden    = true,
      on_open = function(t)
        vim.cmd("startinsert!")
        vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { buffer = t.bufnr })
      end,
    })

    local float_term = Terminal:new({
      direction = "float",
      hidden    = true,
      on_open = function(t)
        vim.cmd("startinsert!")
        vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { buffer = t.bufnr })
      end,
    })

    vim.keymap.set("n", "<leader>at", function() claude_term:toggle() end,
      { desc = "Claude Code (terminal flotante)" })
    vim.keymap.set("n", "<leader>aT", function() float_term:toggle() end,
      { desc = "Terminal flotante" })
  end,
}

return { M_claude_code, M_terminal }
