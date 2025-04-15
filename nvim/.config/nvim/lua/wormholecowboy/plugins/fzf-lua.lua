return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {},
	config = function()
		local wk = require("which-key")
		wk.register({
			s = {
				a = { "<cmd>FzfLua autocmds<cr>", "autocommands" },
				b = { "<cmd>FzfLua buffers<cr>", "buffer" },
				cc = { "<cmd>FzfLua commands<cr>", "nv commands" },
				ch = { "<cmd>FzfLua command_history<cr>", "command_history" },
				cs = { "<cmd>FzfLua colorschemes<cr>", "color scheme" },
				e = { "<cmd>FzfLua changes<cr>", "changes" },
				f = { "<cmd>FzfLua files<cr>", "files" },
				gb = { "<cmd>FzfLua git_branches<cr>", "git branches" },
				gc = { "<cmd>FzfLua git_commits<cr>", "git commits" },
				gf = { "<cmd>FzfLua git_files<cr>", "git files" },
				gh = { "<cmd>FzfLua git_stash<cr>", "git stash" },
				gs = { "<cmd>FzfLua git_status<cr>", "git status" },
				h = { "<cmd>FzfLua helptags<cr>", "help" },
				k = { "<cmd>FzfLua keymaps<cr>", "keymaps" },
				m = { "<cmd>FzfLua marks<cr>", "marks" },
				n = { "<cmd>FzfLua manpages<cr>", "man pages" },
				s = { "<cmd>FzfLua grep<cr>", "string" },
				w = { "<cmd>FzfLua grep_cword<cr>", "word" },
			},
		}, { prefix = "<leader>" })

		local actions = require("fzf-lua").actions
		require("fzf-lua").setup({
			actions = {
				-- Below are the default actions, setting any value in these tables will override
				-- the defaults, to inherit from the defaults change [1] from `false` to `true`
				files = {
					true,        -- uncomment to inherit all the below in your custom config
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
