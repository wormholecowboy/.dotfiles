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

		require("fzf-lua").setup({
			keymap = {
				fzf = {
					["ctrl-q"] = "select-all+accept",
				},
			},
		})
	end,
}
