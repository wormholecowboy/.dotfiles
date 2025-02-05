return {
	"numToStr/Comment.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("Comment").setup()
		local api = require("Comment.api")
		vim.keymap.set("n", "<leader>/", api.toggle.linewise.current)
		-- keymap("x", "<leader>/", '<ESC><CMD>lua require("Comment.api").toggle_linewise_op(vim.fn.visualmode())<CR>')
	end,
}
