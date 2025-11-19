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
		vim.keymap.set("n", "<F7>", ":Trouble diagnostics toggle<cr>", { desc = "Toggle Trouble diagnostics" })
	end,
	opts = {
		focus = true,
    warn_no_results = false,
	},
}
