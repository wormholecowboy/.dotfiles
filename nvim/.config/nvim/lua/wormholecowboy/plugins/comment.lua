return {
	"numToStr/Comment.nvim",
	keys = {
		{
			"<leader>/",
			function()
				require("Comment.api").toggle.linewise.current()
			end,
			desc = "comment line",
		},
		{ "gc", mode = { "n", "v" }, desc = "comment (motion)" },
		{ "gb", mode = { "n", "v" }, desc = "block comment" },
	},
	opts = {},
}
