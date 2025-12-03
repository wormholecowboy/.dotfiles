return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
	},
	config = function()
		-- Get capabilities from cmp_nvim_lsp for autocompletion
		local capabilities = require("cmp_nvim_lsp").default_capabilities()

		-- Server configurations (Neovim 0.11+ vim.lsp.config API)
		-- These are merged with defaults when servers are enabled
		vim.lsp.config("basedpyright", {
			capabilities = capabilities,
			settings = {
				basedpyright = {
					disableOrganizeImports = true,
					analysis = {
						typeCheckingMode = "off",
					},
				},
			},
		})

		vim.lsp.config("lua_ls", {
			capabilities = capabilities,
			settings = {
				Lua = {
					runtime = { version = "LuaJIT" },
					diagnostics = { globals = { "vim" } },
					workspace = { checkThirdParty = false },
					telemetry = { enable = false },
				},
			},
		})

		vim.lsp.config("ts_ls", { capabilities = capabilities })
		vim.lsp.config("bashls", { capabilities = capabilities })
		vim.lsp.config("terraformls", { capabilities = capabilities })

		-- Configure diagnostic display
		vim.diagnostic.config({
			virtual_text = false,
			signs = true,
			update_in_insert = false,
			underline = true,
			severity_sort = true,
			float = {
				border = "rounded",
				source = true, -- Show diagnostic source (fixed: was "always", now boolean)
			},
		})

		-- Configure LSP float window borders (Neovim 0.10+)
		-- Replaces deprecated vim.lsp.with() pattern
		-- Note: In 0.11+, can use vim.o.winborder = 'rounded' instead
		local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
		function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
			opts = opts or {}
			opts.border = opts.border or "rounded"
			return orig_util_open_floating_preview(contents, syntax, opts, ...)
		end

		-- Set up diagnostic signs
		local signs = { Error = "⛔", Warn = "⚠️", Hint = "🔬", Info = "ℹ️" }
		for sign_type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. sign_type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		-- Modern LspAttach autocmd for keybindings (2025 best practice)
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				-- Enable completion triggered by <c-x><c-o>
				vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

				local opts = { buffer = ev.buf, silent = true }

				-- LSP keybindings
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
				vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
				vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)
				vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
				vim.keymap.set("n", "gs", vim.lsp.buf.signature_help, opts)

				-- Code actions and refactoring
				vim.keymap.set({ "n", "v" }, "<leader>uc", vim.lsp.buf.code_action, opts)
				vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, opts)

				-- Diagnostics navigation (Neovim 0.10+ - uses vim.diagnostic.jump)
				vim.keymap.set("n", "[d", function()
					vim.diagnostic.jump({ count = -1 })
				end, opts)
				vim.keymap.set("n", "]d", function()
					vim.diagnostic.jump({ count = 1 })
				end, opts)
				vim.keymap.set("n", "gl", vim.diagnostic.open_float, opts)

				-- Workspace management
				-- ⏺ The workspace folder commands I added are for managing LSP workspaces - they let you control which directories the LSP
				--   server monitors:
				--   - <leader>wa - Add workspace folder
				-- - Adds a directory to the LSP server's workspace
				-- - Useful for monorepos or when working with multiple related projects
				-- - Example: If you're in ~/project/backend but need LSP to also see ~/project/shared, you can add it
				vim.keymap.set("n", "<leader>uwa", vim.lsp.buf.add_workspace_folder, opts)
				vim.keymap.set("n", "<leader>uwr", vim.lsp.buf.remove_workspace_folder, opts)
				vim.keymap.set("n", "<leader>uwl", function()
					print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
				end, opts)

			end,
		})
	end,
}
