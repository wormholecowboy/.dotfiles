return {
	"ThePrimeagen/git-worktree.nvim",
	keys = {
		{
			"<leader>gw",
			"<cmd>lua require('telescope').extensions.git_worktree.git_worktrees()<cr>",
			desc = "worktrees",
		},
		{
			"<leader>gcw",
			"<cmd>lua require('telescope').extensions.git_worktree.create_git_worktree()<cr>",
			desc = "create worktree",
		},
	},
	opts = {
		change_directory_command = "cd",
		update_on_change = true,
		update_on_change_command = "e .",
		clearjumps_on_change = true,
		autopush = false,
	},
}
