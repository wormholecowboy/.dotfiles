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

		vim.lsp.config("ts_ls", {
			capabilities = capabilities,
			-- Workaround for vim.fs.root bug in Neovim 0.12-dev
			root_dir = function(bufnr, on_dir)
				local root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" }
				local root = vim.fs.root(bufnr, root_markers)
				on_dir(root or vim.fn.getcwd())
			end,
		})
		vim.lsp.config("bashls", { capabilities = capabilities })
		vim.lsp.config("terraformls", { capabilities = capabilities })

		-- Configure diagnostic display (Neovim 0.11+ signs API)
		vim.diagnostic.config({
			virtual_text = false,
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = "⛔",
					[vim.diagnostic.severity.WARN] = "⚠️",
					[vim.diagnostic.severity.HINT] = "🔬",
					[vim.diagnostic.severity.INFO] = "ℹ️",
				},
			},
			update_in_insert = false,
			underline = true,
			severity_sort = true,
			float = {
				border = "rounded",
				source = true,
			},
		})

		-- Configure LSP handlers for rounded borders
		vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
		vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

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
