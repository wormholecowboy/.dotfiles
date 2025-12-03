return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  keys = {
    { "<leader>m", "<cmd>MarkdownPreviewToggle<cr>", desc = "markdown preview" },
  },
  build = function(plugin)
    if vim.fn.executable("npx") then
      vim.cmd("!cd " .. plugin.dir .. " && cd app && npx --yes yarn install && npm install")
    else
      vim.cmd([[Lazy load markdown-preview.nvim]])
      vim.fn["mkdp#util#install"]()
    end
  end,
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
  end,
  ft = { "markdown" },
  config = function()
    vim.g.mkdp_auto_start = 0
  end,

  --NOTE: If you have issues, try cleaning an rebuilding. If all else fails, try a manual build with their install.sh
  --https://github.com/iamcco/markdown-preview.nvim/issues/424
}
