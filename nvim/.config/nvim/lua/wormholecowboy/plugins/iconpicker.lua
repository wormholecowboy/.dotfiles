return {
	"ziontee113/icon-picker.nvim",
	dependencies = {
		"stevearc/dressing.nvim",
		"nvim-telescope/telescope.nvim",
	},
	keys = {
		{ "<C-e>", "<cmd>IconPickerInsert<cr>", mode = "i", desc = "insert emoji" },
	},
	opts = {
		disable_legacy_commands = true,
	},
}
