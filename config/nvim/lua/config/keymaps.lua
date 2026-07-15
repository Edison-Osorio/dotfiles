local map = vim.keymap.set

-- ── Oil ──────────────────────────────────────────────────────────────────────
map("n", "-", "<CMD>Oil<CR>", { desc = "Open file explorer" })

-- ── Navigation ──────────────────────────────────────────────────────────────
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Move lines
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Keep cursor centered when jumping
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Better paste (don't lose register)
map("x", "<leader>p", [["_dP]], { desc = "Paste without yank" })

-- ── Diagnostics ──────────────────────────────────────────────────────────────
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })

-- ── LSP (extra shortcuts beyond LazyVim defaults) ────────────────────────────
map("n", "<leader>cr", vim.lsp.buf.rename,      { desc = "Rename symbol" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })

-- ── Quickfix ─────────────────────────────────────────────────────────────────
map("n", "<leader>Q", "<cmd>cclose<cr>", { desc = "Close quickfix" })
map("n", "]q", "<cmd>cnext<cr>",         { desc = "Next quickfix" })
map("n", "[q", "<cmd>cprev<cr>",         { desc = "Prev quickfix" })
