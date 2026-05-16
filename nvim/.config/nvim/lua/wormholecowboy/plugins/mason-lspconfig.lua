return {
	"williamboman/mason-lspconfig.nvim",
	dependencies = {
		{ "williamboman/mason.nvim", opts = {} },
		"neovim/nvim-lspconfig",
	},
	opts = {
		-- Automatically install these LSP servers
		ensure_installed = {
			"basedpyright", -- Python
			"ts_ls", -- JavaScript/TypeScript
			"bashls", -- Bash
			"terraformls", -- Terraform
			"lua_ls", -- Lua
			"gopls", -- Go
		},
		-- v2.0+ automatically enables installed servers via vim.lsp.enable()
		-- Server configs are defined via vim.lsp.config() in lspconfig.lua
		-- Reason: stylua is mason-installed as a formatter (conform), not an LSP — exclude it
		-- so mason-lspconfig doesn't try to start it with --lsp (stylua 2.x dropped LSP mode)
		automatic_enable = {
			exclude = { "stylua" },
		},
	},
}
