return {
	"folke/trouble.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = { "nvim-tree/nvim-web-devicons" },
	cmd = "Trouble",
	-- keys = {
	-- 	{
	-- 		"<leader>D",
	-- 		"<cmd>Trouble diagnostics toggle<cr>",
	-- 		desc = "Diagnostics (Trouble)",
	-- 	},
	-- },
	config = function()
		require("trouble").setup()
		vim.keymap.set("n", "<leader>D", ":Trouble diagnostics toggle<cr>, {}")
	end,
	opts = {
		focus = true,
    warn_no_results = false,
	},
}
