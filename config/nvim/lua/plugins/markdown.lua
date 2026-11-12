-- Visualizador de Markdown (estilo Gentleman.Dots)
-- El extra lazyvim.plugins.extras.lang.markdown (en init.lua) instala:
--   - render-markdown.nvim  → renderiza el markdown dentro del buffer
--   - markdown-preview.nvim → vista previa en vivo en el navegador
--   - marksman (LSP) + markdownlint
-- Atajos:
--   <leader>um → activar/desactivar el render dentro del buffer
--   <leader>cp → abrir/cerrar la vista previa en el navegador
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      file_types = { "markdown", "norg", "rmd", "org", "codecompanion" },
      render_modes = { "n", "c", "t" }, -- en modo insertar se ve el texto crudo
      anti_conceal = { enabled = true }, -- muestra el texto crudo en la línea del cursor
      heading = {
        sign = false,
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
        width = "full",
        border = false,
      },
      code = {
        sign = false,
        style = "full",
        width = "block",
        left_pad = 1,
        right_pad = 1,
        border = "thin",
      },
      bullet = { icons = { "●", "○", "◆", "◇" } },
      checkbox = {
        unchecked = { icon = "󰄱 " },
        checked = { icon = "󰱒 " },
        custom = {
          todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
        },
      },
      pipe_table = { preset = "round" },
      quote = { repeat_linebreak = true },
    },
  },
  {
    "iamcco/markdown-preview.nvim",
    init = function()
      vim.g.mkdp_auto_close = 1 -- cierra la vista previa al salir del buffer
      vim.g.mkdp_theme = "dark"
      vim.g.mkdp_combine_preview = 1 -- reutiliza la misma pestaña del navegador
    end,
  },
}
