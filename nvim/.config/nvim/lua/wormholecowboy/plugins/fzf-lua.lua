return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	keys = {
		{ "<leader>sa", "<cmd>FzfLua files fd_opts='--color=never --hidden --type f --type l --no-ignore'<cr>", desc = "all files" },
		{ "<leader>sA", "<cmd>FzfLua autocmds<cr>", desc = "autocommands" },
		{ "<leader>sb", "<cmd>FzfLua buffers<cr>", desc = "buffers" },
		{ "<leader>scc", "<cmd>FzfLua commands<cr>", desc = "commands" },
		{ "<leader>sch", "<cmd>FzfLua command_history<cr>", desc = "command history" },
		{ "<leader>scs", "<cmd>FzfLua colorschemes<cr>", desc = "colorschemes" },
		{ "<leader>se", "<cmd>FzfLua changes<cr>", desc = "changes" },
		{ "<leader>sf", "<cmd>FzfLua files<cr>", desc = "files" },
		{ "<leader>sgf", "<cmd>FzfLua git_files<cr>", desc = "git files" },
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
	},
	opts = function()
		local actions = require("fzf-lua").actions
		return {
			actions = {
				files = {
					true,
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
			files = {
				fd_opts = [[--color=never --hidden --type f --type l --exclude .git]],
				rg_opts = [[--color=never --hidden --files -g "!.git"]],
			},
			keymap = {
				fzf = {
					["ctrl-q"] = "select-all+accept",
				},
			},
		}
	end,
}
