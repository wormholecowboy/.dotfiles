return {
  "ThePrimeagen/git-worktree.nvim",
  config = function ()
    require("git-worktree").setup({
    change_directory_command = "cd",
    update_on_change = true,
    update_on_change_command = "e .",
    clearjumps_on_change = true,
    autopush = false
})

    vim.keymap.set("n", "<leader>gw", "<cmd>lua require('telescope').extensions.git_worktree.git_worktrees()<cr>", {})
    vim.keymap.set("n", "<leader>gcw", "<cmd>lua require('telescope').extensions.git_worktree.create_git_worktree()<cr>", {})
     
  end
}
