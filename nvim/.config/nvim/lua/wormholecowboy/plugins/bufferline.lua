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
      show_buffer_icons = false,
      highlight = { underline = true, sp = "blue" },
      buffer_close_icon = "",
    },
  },
  config = function(_, opts)
    require("bufferline").setup(opts)

    -- Make the active tab match lualine's mode block by linking bufferline's
    -- selected-buffer groups to lualine's mode group (lualine_a_normal).
    -- Re-applied on ColorScheme because bufferline rebuilds its highlights on
    -- theme changes and would otherwise clobber the links.
    local function link_mode_color()
      for _, group in ipairs({
        "BufferLineBufferSelected",
        "BufferLineNumbersSelected",
        "BufferLineModifiedSelected",
        "BufferLineDuplicateSelected",
        "BufferLineCloseButtonSelected",
      }) do
        vim.api.nvim_set_hl(0, group, { link = "lualine_a_normal" })
      end
    end

    link_mode_color()
    vim.api.nvim_create_autocmd("ColorScheme", { callback = link_mode_color })
  end,
}
