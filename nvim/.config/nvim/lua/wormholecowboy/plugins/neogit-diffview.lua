return {
	"NeogitOrg/neogit",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"sindrets/diffview.nvim",
		"ibhagwan/fzf-lua",
	},
	config = function()
		vim.keymap.set("n", "<leader>gg", "<cmd>Neogit<cr>")
		vim.keymap.set("n", "<leader>gv", "<cmd>DiffviewOpen<cr>")
		vim.keymap.set("n", "<leader>gx", "<cmd>DiffviewClose<cr>")
	end,
}
