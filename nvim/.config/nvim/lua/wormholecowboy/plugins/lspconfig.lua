return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
	},
	config = function()
		-- Configure diagnostic display
		vim.diagnostic.config({
			virtual_text = true,
			signs = true,
			update_in_insert = false,
			underline = true,
			severity_sort = true,
			float = {
				border = "rounded",
				source = "always",
			},
		})

		-- Configure LSP handlers for nice borders
		vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
			border = "rounded",
		})

		vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
			border = "rounded",
		})

		-- Set up diagnostic signs
		local signs = { Error = "⛔", Warn = "⚠️", Hint = "🔬", Info = "ℹ️" }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
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

				-- Diagnostics navigation
				vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
				vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
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

				-- Formatting (if supported by the LSP)
				local client = vim.lsp.get_client_by_id(ev.data.client_id)
				if client and client.supports_method("textDocument/formatting") then
					vim.keymap.set("n", "<leader>f", function()
						vim.lsp.buf.format({ async = true })
					end, opts)
				end
			end,
		})
	end,
}
