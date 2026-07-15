return {
  -- Deshabilitar tabs (bufferline)
  { "akinsho/bufferline.nvim", enabled = false },


  -- Nombre de archivo flotante (estilo gentleman) arriba derecha de cada ventana
  {
    "b0o/incline.nvim",
    event = "BufReadPre",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local devicons = require("nvim-web-devicons")

      require("incline").setup({
        highlight = {
          groups = {
            InclineNormal         = { default = true, group = "NormalFloat" },
            InclineNormalNC       = { default = true, group = "NormalFloat" },
          },
        },
        window = {
          margin  = { vertical = 0, horizontal = 1 },
          padding = { left = 1, right = 1 },
          placement = { horizontal = "right", vertical = "top" },
          winhighlight = {
            active   = { EndOfBuffer = "None", Normal = "InclineNormal" },
            inactive = { EndOfBuffer = "None", Normal = "InclineNormalNC" },
          },
        },
        render = function(props)
          -- Ocultar cuando el cursor está en la primera línea visible
          local top_line    = vim.fn.line("w0", props.win)
          local cursor_line = vim.api.nvim_win_get_cursor(props.win)[1]
          if cursor_line == top_line then
            return false
          end

          local bufname  = vim.api.nvim_buf_get_name(props.buf)
          local filename = bufname ~= "" and vim.fn.fnamemodify(bufname, ":.") or "[sin nombre]"
          local ext      = vim.fn.fnamemodify(filename, ":e")
          local icon, icon_color = devicons.get_icon_color(filename, ext, { default = true })
          local modified = vim.bo[props.buf].modified

          return {
            { icon .. " ",  guifg = icon_color },
            { filename,     gui   = modified and "bold,italic" or "bold" },
            modified and { " ●", guifg = "#F5A97F" } or "",
          }
        end,
      })

      -- Forzar re-render al mover el cursor para que el hide/show sea inmediato
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        callback = function()
          require("incline").refresh()
        end,
      })
    end,
  },
}
