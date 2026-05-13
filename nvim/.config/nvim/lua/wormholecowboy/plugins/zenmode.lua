return {
  "folke/zen-mode.nvim",
  keys = {
    { "<leader>z", "<cmd>ZenMode<cr>", desc = "zen mode" },
  },
  opts = {
    on_open = function()
      if vim.g.writing_mode then
        require("cmp").setup.buffer({ enabled = false })
        vim.wo.wrap = true
        vim.wo.linebreak = true
        vim.o.so = 1
      end
    end,
    on_close = function()
      if vim.g.writing_mode then
        pcall(function()
          require("cmp").setup.buffer({ enabled = true })
        end)
        vim.wo.wrap = false
        vim.wo.linebreak = false
        vim.o.so = 8
        vim.g.writing_mode = false
      end
    end,
  },
}
