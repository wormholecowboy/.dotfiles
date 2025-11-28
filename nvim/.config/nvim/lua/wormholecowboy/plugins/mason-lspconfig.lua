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
		},
		-- v2.0+ automatically enables installed servers via vim.lsp.enable()
		-- Server configs are defined via vim.lsp.config() in lspconfig.lua
	},
}
