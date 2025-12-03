return {
	"stevearc/aerial.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	keys = {
		{ "<leader>t", "<cmd>AerialToggle!<cr>", desc = "code outline" },
	},
	opts = {
		backends = { "treesitter", "lsp", "markdown", "asciidoc", "man" },
		layout = {
			max_width = { 40, 0.2 },
			width = nil,
			min_width = 10,
		},
		lazy_load = true,
		close_on_select = true,
		autojump = true,
		default_direction = "prefer_left",
		highlight_on_hover = true,
		on_attach = function(bufnr)
			-- Buffer-local keymaps must stay here
			vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr, desc = "prev symbol" })
			vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr, desc = "next symbol" })
		end,
	},
}
