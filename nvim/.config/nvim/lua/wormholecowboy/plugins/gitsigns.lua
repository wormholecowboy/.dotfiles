return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("gitsigns").setup({
			signs = {
				add = { text = "+" },
				change = { text = "│" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "┆" },
			},
			signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
			numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
			linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
			word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
			watch_gitdir = {
				follow_files = true,
			},
			attach_to_untracked = true,
			current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
				delay = 1000,
				ignore_whitespace = false,
				virt_text_priority = 100,
			},
			current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
			sign_priority = 6,
			update_debounce = 100,
			status_formatter = nil, -- Use default
			max_file_length = 40000, -- Disable if file is longer than this (in lines)
			preview_config = {
				-- Options passed to nvim_open_win
				border = "single",
				style = "minimal",
				relative = "cursor",
				row = 0,
				col = 1,
			},
		})

		local wk = require("which-key")
		wk.add({
			{ "<leader>hb", "<cmd>Gitsigns blame_line<cr>", desc = "blame" },
			{ "<leader>hp", "<cmd>Gitsigns preview_hunk<cr>", desc = "preview" },
			{ "<leader>he", "<cmd>Gitsigns select_hunk<cr>", desc = "select" },
			{ "<leader>hs", "<cmd>Gitsigns stage_hunk<cr>", desc = "stage" },
			{ "<leader>hr", "<cmd>Gitsigns reset_hunk<cr>", desc = "reset hunk" },
			{ "<leader>hR", "<cmd>Gitsigns reset_buffer<cr>", desc = "reset buffer" },
			{ "<leader>hl", "<cmd>Gitsigns toggle_deleted<cr>", desc = "toggle deleted" },
			{ "<leader>hu", "<cmd>Gitsigns undo_stage_hunk<cr>", desc = "undo last staged hunk" },
			{ "<leader>hd", "<cmd>Gitsigns diffthis HEAD<cr>", desc = "diff" },
			{ "]c", "<cmd>lua require 'gitsigns'.next_hunk({navigation_message = false})<cr>", desc = "Next Hunk" },
			{ "[c", "<cmd>lua require 'gitsigns'.prev_hunk({navigation_message = false})<cr>", desc = "Prev Hunk" },
		})
	end,
}
