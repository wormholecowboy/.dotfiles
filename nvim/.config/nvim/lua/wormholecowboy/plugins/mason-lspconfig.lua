return {
	"williamboman/mason-lspconfig.nvim",
	dependencies = {
		"williamboman/mason.nvim",
		"neovim/nvim-lspconfig",
	},
	config = function()
		local mason_lspconfig = require("mason-lspconfig")

		-- Get capabilities from cmp_nvim_lsp for autocompletion
		local capabilities = require("cmp_nvim_lsp").default_capabilities()

		mason_lspconfig.setup({
			-- Automatically install these LSP servers
			ensure_installed = {
				"basedpyright", -- Python (modern fork with inlay hints)
				"ts_ls", -- JavaScript/TypeScript
				"bashls", -- Bash
				"terraformls", -- Terraform
				"lua_ls", -- Lua
			},

			-- Modern handlers-based approach (2025 best practice)
			-- This automatically configures all installed servers
			handlers = {
				-- Default handler for all servers
				function(server_name)
					require("lspconfig")[server_name].setup({
						capabilities = capabilities,
					})
				end,

				-- Custom configuration for basedpyright
				["basedpyright"] = function()
					require("lspconfig").basedpyright.setup({
						capabilities = capabilities,
						settings = {
							basedpyright = {
								analysis = {
									diagnosticSeverityOverrides = {
										reportMissingTypeStubs = "none",
										reportOptionalMemberAccess = "none",
										reportGeneralTypeIssues = "none",
										reportAttributeAccessIssue = "none",
										reportUnknownMemberType = "none",
										reportUnknownVariableType = "none",
										reportDeprecated = "none",
									},
								},
							},
						},
					})
				end,

				-- Custom configuration for lua_ls (lazydev.nvim handles workspace libraries)
				["lua_ls"] = function()
					require("lspconfig").lua_ls.setup({
						capabilities = capabilities,
						settings = {
							Lua = {
								runtime = {
									version = "LuaJIT",
								},
								diagnostics = {
									-- Recognize the `vim` global
									globals = { "vim" },
								},
								workspace = {
									-- lazydev.nvim handles library loading dynamically
									checkThirdParty = false,
								},
								telemetry = {
									enable = false,
								},
							},
						},
					})
				end,
			},
		})
	end,
}
