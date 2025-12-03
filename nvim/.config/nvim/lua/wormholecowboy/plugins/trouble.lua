return {
	"folke/trouble.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	cmd = "Trouble",
	keys = {
		{ "<F7>", "<cmd>Trouble diagnostics toggle<cr>", desc = "diagnostics" },
	},
	opts = {
		focus = true,
		warn_no_results = false,
	},
}
