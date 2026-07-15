local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Django HTML templates
vim.filetype.add({
  pattern = {
    [".*templates/.*%.html"] = "htmldjango",
    [".*templates/.*%.htm"]  = "htmldjango",
    [".*jinja2/.*%.html"]    = "htmldjango",
  },
})

-- Angular HTML templates
vim.filetype.add({
  pattern = {
    [".*%.component%.html"] = "html",
  },
})

-- Python: indent 4 spaces (PEP 8)
autocmd("FileType", {
  group   = augroup("python_indent", { clear = true }),
  pattern = { "python" },
  callback = function()
    vim.opt_local.tabstop    = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab  = true
  end,
})

-- TypeScript/Angular: 2 spaces
autocmd("FileType", {
  group   = augroup("ts_indent", { clear = true }),
  pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact", "html" },
  callback = function()
    vim.opt_local.tabstop    = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab  = true
  end,
})

-- Auto-close quickfix when it's the last window
autocmd("WinEnter", {
  group = augroup("auto_close_qf", { clear = true }),
  callback = function()
    if vim.fn.winnr("$") == 1 and vim.bo.buftype == "quickfix" then
      vim.cmd("quit")
    end
  end,
})

-- Highlight on yank
autocmd("TextYankPost", {
  group    = augroup("highlight_yank", { clear = true }),
  callback = function() vim.highlight.on_yank({ timeout = 150 }) end,
})

-- Update python3_host_prog when venv changes
vim.api.nvim_create_autocmd("User", {
  pattern  = "VenvSelectorActivated",
  callback = function(ev)
    local python = ev.data and ev.data.python_path
    if python then
      vim.g.python3_host_prog = python
    end
  end,
})
