vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local opt = vim.opt

-- UI
opt.number         = true
opt.relativenumber = true
opt.cursorline     = true
opt.signcolumn     = "yes"
opt.termguicolors  = true
opt.scrolloff      = 8
opt.sidescrolloff  = 8
opt.splitright     = true
opt.splitbelow     = true
opt.showmode       = false
opt.cmdheight      = 1
opt.pumheight      = 10

-- Indentation — 2 spaces default (overridden per filetype)
opt.tabstop     = 2
opt.shiftwidth  = 2
opt.expandtab   = true
opt.smartindent = true

-- Search
opt.ignorecase = true
opt.smartcase  = true
opt.hlsearch   = true

-- Files
opt.undofile   = true
opt.swapfile   = false
opt.backup     = false
opt.updatetime = 200

-- Completion
opt.completeopt = { "menu", "menuone", "noselect" }

-- Clipboard: use system clipboard
opt.clipboard = "unnamedplus"

-- Folding (use treesitter)
opt.foldmethod = "expr"
opt.foldexpr   = "nvim_treesitter#foldexpr()"
opt.foldenable = false

-- Python provider: prefer the virtualenv python when available
vim.g.python3_host_prog = vim.fn.exepath("python3")
