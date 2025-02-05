return {
  "phaazon/hop.nvim",
  event = { "BufReadPre", "BufNewFile" },
  branch = "v2",
  config = function()
    require("hop").setup({ keys = "etovxqpdygfblzhckisuran" })
    vim.keymap.set("n", "<leader>f", "<cmd>:HopWord<CR>", {})
  end,
}
