return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {},
	config = function()
		local wk = require("which-key")
		wk.add({
			{ "<leader>sa", "<cmd>FzfLua autocmds<cr>", desc = "autocommands" },
			{ "<leader>sb", "<cmd>FzfLua buffers<cr>", desc = "buffer" },
			{ "<leader>scc", "<cmd>FzfLua commands<cr>", desc = "nv commands" },
			{ "<leader>sch", "<cmd>FzfLua command_history<cr>", desc = "command_history" },
			{ "<leader>scs", "<cmd>FzfLua colorschemes<cr>", desc = "color scheme" },
			{ "<leader>se", "<cmd>FzfLua changes<cr>", desc = "changes" },
			{ "<leader>sx", "<cmd>FzfLua files<cr>", desc = "files" },
			{ "<leader>sf", "<cmd>FzfLua git_files<cr>", desc = "git files" },
			{ "<leader>sgb", "<cmd>FzfLua git_branches<cr>", desc = "git branches" },
			{ "<leader>sgc", "<cmd>FzfLua git_commits<cr>", desc = "git commits" },
			{ "<leader>sgh", "<cmd>FzfLua git_stash<cr>", desc = "git stash" },
			{ "<leader>sgs", "<cmd>FzfLua git_status<cr>", desc = "git status" },
			{ "<leader>sh", "<cmd>FzfLua helptags<cr>", desc = "help" },
			{ "<leader>sk", "<cmd>FzfLua keymaps<cr>", desc = "keymaps" },
			{ "<leader>sm", "<cmd>FzfLua marks<cr>", desc = "marks" },
			{ "<leader>sn", "<cmd>FzfLua manpages<cr>", desc = "man pages" },
			{ "<leader>ss", "<cmd>FzfLua grep<cr>", desc = "string" },
			{ "<leader>sw", "<cmd>FzfLua grep_cword<cr>", desc = "word" },
		})

		local actions = require("fzf-lua").actions
		require("fzf-lua").setup({
			actions = {
				-- Below are the default actions, setting any value in these tables will override
				-- the defaults, to inherit from the defaults change [1] from `false` to `true`
				files = {
					true, -- uncomment to inherit all the below in your custom config
					-- Pickers inheriting these actions:
					--   files, git_files, git_status, grep, lsp, oldfiles, quickfix, loclist,
					--   tags, btags, args, buffers, tabs, lines, blines
					-- `file_edit_or_qf` opens a single selection or sends multiple selection to quickfix
					-- replace `enter` with `file_edit` to open all files/bufs whether single or multiple
					-- replace `enter` with `file_switch_or_edit` to attempt a switch in current tab first
					["enter"] = actions.file_edit_or_qf,
					["ctrl-h"] = actions.file_split,
					["ctrl-s"] = actions.file_vsplit,
					["ctrl-t"] = actions.file_tabedit,
					["alt-q"] = actions.file_sel_to_qf,
					["alt-Q"] = actions.file_sel_to_ll,
					["alt-i"] = actions.toggle_ignore,
					["alt-h"] = actions.toggle_hidden,
					["alt-f"] = actions.toggle_follow,
				},
			},

			keymap = {
				fzf = {
					["ctrl-q"] = "select-all+accept",
				},
			},
		})
	end,
}
