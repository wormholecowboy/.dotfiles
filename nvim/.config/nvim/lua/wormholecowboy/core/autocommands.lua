
vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("ShowFullPath", { clear = true }),
  desc = "Show full path of current buffer",
  pattern = "*",
  callback = function()
    vim.keymap.set("n", "<leader>ub", function()
      local full_path = vim.fn.expand("%:p")
      print(full_path)
    end, { buffer = 0, desc = "Show full path of current buffer" })
 end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
  desc = "Hightlight selection on yank",
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("WritingMode", { clear = true }),
  desc = "Writing Mode",
  pattern = "*",
  callback = function()
    vim.keymap.set("n", "<leader>q", function()
      vim.cmd("ZenMode")
      require("cmp").setup.buffer({ enabled = false })
      vim.wo.wrap = true
      vim.wo.linebreak = true
    end, { buffer = 0, desc = "Writing mode engaged" })
  end,
})

-- vim.diagnostic.config({virtual_text = false, underline = true})
-- this will disable lsp diagnostics
--
-- toggle script for lsp diagnostic
vim.api.nvim_create_user_command("DiagnosticsToggleVirtualText", function()
  local current_value = vim.diagnostic.config().virtual_text
  if current_value then
    vim.diagnostic.config({ virtual_text = false })
  else
    vim.diagnostic.config({ virtual_text = true })
  end
end, {}) --
--
