return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  version = "*",
  event = { "BufReadPre", "BufNewFile" },
  keys = {
    { "[b", "<cmd>BufferLineMovePrev<cr>", desc = "move buffer left" },
    { "]b", "<cmd>BufferLineMoveNext<cr>", desc = "move buffer right" },
  },
  opts = {
    options = {
      mode = "buffers",
      diagnostics = "nvim_lsp",
      indicator = {
        style = "underline",
      },
      highlight = { underline = true, sp = "blue" },
      buffer_close_icon = "",
    },
  },
}
