local function write()
	vim.opt.wrap = true
	vim.opt.linebreak = true
	require("cmp").setup.buffer({ enabled = false })
end

lvim.builtin.which_key.mappings[";"] = { "<cmd>ToggleTerm<cr>", "Terminal" }
lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }
lvim.builtin.which_key.mappings["b"] = { "<cmd>Telescope buffers<cr>", "Buffers" }
lvim.builtin.which_key.mappings["v"] = { "<cmd>vsplit<cr>", "vsplit" }
lvim.builtin.which_key.mappings["w"] = { "<cmd>w<CR>", "Write" }
lvim.builtin.which_key.mappings["q"] = { '<cmd>lua require("user.functions").smart_quit()<CR>', "Quit" }
lvim.builtin.which_key.mappings["/"] = { '<cmd>lua require("Comment.api").toggle.linewise.current()<CR>', "Comment" }
lvim.builtin.which_key.mappings["c"] = { "<cmd>bdelete!<CR>", "Close Buffer" }
lvim.builtin.which_key.mappings["h"] = nil
-- lvim.builtin.which_key.mappings["gy"] = "Link"
-- lvim.builtin.which_key.mappings["s"] = nil
lvim.builtin.which_key.mappings["<leader>"] = {
	name = "Hop",
	f = { "<cmd>HopWord<CR>", "All Words" },
	a = { "<cmd>HopAnywhere<CR>", "Anywhere" },
	l = { "<cmd>HopLine<CR>", "Line" },
	p = { "<cmd>HopPattern<CR>", "Pattern" },
}
lvim.builtin.which_key.mappings["t"] = {
	name = "+Trouble",
	r = { "<cmd>Trouble lsp_references<cr>", "References" },
	f = { "<cmd>Trouble lsp_definitions<cr>", "Definitions" },
	d = { "<cmd>Trouble document_diagnostics<cr>", "Diagnostics" },
	q = { "<cmd>Trouble quickfix<cr>", "QuickFix" },
	l = { "<cmd>Trouble loclist<cr>", "LocationList" },
	w = { "<cmd>Trouble workspace_diagnostics<cr>", "Workspace Diagnostics" },
}
-- lvim.builtin.which_key.mappings["r"] = {
--   name = "Replace",
--   r = { "<cmd>lua require('spectre').open()<cr>", "Replace" },
--   w = { "<cmd>lua require('spectre').open_visual({select_word=true})<cr>", "Replace Word" },
--   f = { "<cmd>lua require('spectre').open_file_search()<cr>", "Replace Buffer" },
-- }
lvim.builtin.which_key.mappings["d"] = {
	name = "Debug",
	b = { "<cmd>lua require'dap'.toggle_breakpoint()<cr>", "Breakpoint" },
	c = { "<cmd>lua require'dap'.continue()<cr>", "Continue" },
	i = { "<cmd>lua require'dap'.step_into()<cr>", "Into" },
	o = { "<cmd>lua require'dap'.step_over()<cr>", "Over" },
	O = { "<cmd>lua require'dap'.step_out()<cr>", "Out" },
	r = { "<cmd>lua require'dap'.repl.toggle()<cr>", "Repl" },
	l = { "<cmd>lua require'dap'.run_last()<cr>", "Last" },
	u = { "<cmd>lua require'dapui'.toggle()<cr>", "UI" },
	x = { "<cmd>lua require'dap'.terminate()<cr>", "Exit" },
}
lvim.builtin.which_key.mappings["u"] = {
	name = "User",
	z = { "<cmd>Goyo<cr>", "Zen Mode" },
	w = {
		-- "<cmd>require('cmp').setup.buffer({ enabled = false })",
		write(),
		"Writing Mode",
	},
}
lvim.builtin.which_key.mappings["U"] = {
	name = "User Paths",
	z = { "<cmd>edit $HOME/.dotfiles/zsh/.zshrc<cr>", "Zsh Config" },
	v = { "<cmd>edit $HOME/.dotfiles/lvim/.config/lvim/lua/brian/<cr>", "Vim Config" },
	n = { "<cmd>edit $HOME/Dropbox/sync/mynotes<cr>", "My Notes" },
	-- n = { "<cmd>lua require('telescope.builtin').find_files({ "~/mynotes"})" },
}
lvim.builtin.which_key.mappings["f"] = {
	name = "Find",
	b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
	c = { "<cmd>Telescope colorscheme<cr>", "Colorscheme" },
	f = { "<cmd>Telescope find_files<cr>", "Find files" },
	t = { "<cmd>Telescope live_grep<cr>", "Find Text" },
	s = { "<cmd>Telescope grep_string<cr>", "Find String" },
	h = { "<cmd>Telescope help_tags<cr>", "Help" },
	H = { "<cmd>Telescope highlights<cr>", "Highlights" },
	-- i = { "<cmd>lua require('telescope').extensions.media_files.media_files()<cr>", "Media" },
	l = { "<cmd>Telescope resume<cr>", "Last Search" },
	M = { "<cmd>Telescope man_pages<cr>", "Man Pages" },
	r = { "<cmd>Telescope oldfiles<cr>", "Recent File" },
	R = { "<cmd>Telescope registers<cr>", "Registers" },
	k = { "<cmd>Telescope keymaps<cr>", "Keymaps" },
	C = { "<cmd>Telescope commands<cr>", "Commands" },
}
lvim.builtin.which_key.mappings["g"] = {
	name = "Git",
	g = "Lazygit",
	j = { "<cmd>lua require 'gitsigns'.next_hunk()<cr>", "Next Hunk" },
	k = { "<cmd>lua require 'gitsigns'.prev_hunk()<cr>", "Prev Hunk" },
	l = { "<cmd>GitBlameToggle<cr>", "Blame" },
	p = { "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", "Preview Hunk" },
	r = { "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", "Reset Hunk" },
	R = { "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", "Reset Buffer" },
	s = { "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", "Stage Hunk" },
	u = {
		"<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>",
		"Undo Stage Hunk",
	},
	o = { "<cmd>Telescope git_status<cr>", "Open changed file" },
	b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
	c = { "<cmd>Telescope git_commits<cr>", "Checkout commit" },
	d = {
		"<cmd>Gitsigns diffthis HEAD<cr>",
		"Diff",
	},
	G = {
		name = "Gist",
		a = { "<cmd>Gist -b -a<cr>", "Create Anon" },
		d = { "<cmd>Gist -d<cr>", "Delete" },
		f = { "<cmd>Gist -f<cr>", "Fork" },
		g = { "<cmd>Gist -b<cr>", "Create" },
		l = { "<cmd>Gist -l<cr>", "List" },
		p = { "<cmd>Gist -b -p<cr>", "Create Private" },
	},
}
lvim.builtin.which_key.mappings["l"] = {
	name = "LSP",
	a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code Action" },
	c = { "<cmd>lua require('user.lsp').server_capabilities()<cr>", "Get Capabilities" },
	d = { "<cmd>TroubleToggle<cr>", "Diagnostics" },
	w = {
		"<cmd>Telescope lsp_workspace_diagnostics<cr>",
		"Workspace Diagnostics",
	},
	f = { "<cmd>lua vim.lsp.buf.format({ async = true })<cr>", "Format" },
	F = { "<cmd>LspToggleAutoFormat<cr>", "Toggle Autoformat" },
	i = { "<cmd>LspInfo<cr>", "Info" },
	h = { "<cmd>lua require('lsp-inlayhints').toggle()<cr>", "Toggle Hints" },
	H = { "<cmd>IlluminationToggle<cr>", "Toggle Doc HL" },
	I = { "<cmd>LspInstallInfo<cr>", "Installer Info" },
	j = {
		"<cmd>lua vim.diagnostic.goto_next({buffer=0})<CR>",
		"Next Diagnostic",
	},
	k = {
		"<cmd>lua vim.diagnostic.goto_prev({buffer=0})<cr>",
		"Prev Diagnostic",
	},
	v = { "<cmd>lua require('lsp_lines').toggle()<cr>", "Virtual Text" },
	l = { "<cmd>lua vim.lsp.codelens.run()<cr>", "CodeLens Action" },
	o = { "<cmd>SymbolsOutline<cr>", "Outline" },
	q = { "<cmd>lua vim.lsp.diagnostic.set_loclist()<cr>", "Quickfix" },
	r = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" },
	R = { "<cmd>TroubleToggle lsp_references<cr>", "References" },
	s = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" },
	S = {
		"<cmd>Telescope lsp_dynamic_workspace_symbols<cr>",
		"Workspace Symbols",
	},
	t = { '<cmd>lua require("user.functions").toggle_diagnostics()<cr>', "Toggle Diagnostics" },
	u = { "<cmd>LuaSnipUnlinkCurrent<cr>", "Unlink Snippet" },
}
