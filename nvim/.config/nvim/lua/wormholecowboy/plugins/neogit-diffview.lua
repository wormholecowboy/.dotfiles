return {
	"NeogitOrg/neogit",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"sindrets/diffview.nvim",
		"ibhagwan/fzf-lua",
	},
	config = function()
		require("neogit").setup({
			commit_editor = {
				kind = "vsplit",
				show_staged_diff = true,
				-- Accepted values:
				-- "split" to show the staged diff below the commit editor
				-- "vsplit" to show it to the right
				-- "split_above" Like :top split
				-- "vsplit_left" like :vsplit, but open to the left
				-- "auto" "vsplit" if window would have 80 cols, otherwise "split"
				staged_diff_split_kind = "split",
				spell_check = true,
			},
		})
		vim.keymap.set("n", "<leader>gg", "<cmd>Neogit<cr>")
		vim.keymap.set("n", "<leader>gv", "<cmd>DiffviewOpen<cr>")
		vim.keymap.set("n", "<leader>gx", "<cmd>DiffviewClose<cr>")
	end,
}
