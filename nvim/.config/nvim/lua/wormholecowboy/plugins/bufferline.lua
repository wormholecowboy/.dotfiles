return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  version = "*",
  config = function()
    require("bufferline").setup({
      options = {
        mode = "buffers",
        diagnostics = "nvim_lsp",
        indicator = {
          -- icon = "▎", -- this should be omitted if indicator style is not 'icon'
          style = "underline",
        },
        highlight = { underline = true, sp = "blue" }, -- Optional
        buffer_close_icon = "",
      },
    })
    vim.keymap.set("n", "[b", ":BufferLineMovePrev<cr>")
    vim.keymap.set("n", "]b", ":BufferLineMoveNext<cr>")
  end,
}
