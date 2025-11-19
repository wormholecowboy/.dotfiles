return {
	"folke/lazydev.nvim",
	ft = "lua", -- only load on lua files
	opts = {
		library = {
			-- Load luvit types when the `vim.uv` word is found
			{ path = "luvit-meta/library", words = { "vim%.uv" } },
			-- Load lazy.nvim types
			{ path = "lazy.nvim", words = { "lazy" } },
		},
	},
}
