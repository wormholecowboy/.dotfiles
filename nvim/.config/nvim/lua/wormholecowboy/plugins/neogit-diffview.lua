return {
	"NeogitOrg/neogit",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"sindrets/diffview.nvim",
		"ibhagwan/fzf-lua",
	},
	config = function()
		-- Neogit setup
		require("neogit").setup({
			commit_editor = {
				kind = "vsplit",
				show_staged_diff = true,
				staged_diff_split_kind = "split",
				spell_check = true,
			},
			prompt_force_push = false,
			disable_line_numbers = false,
			disable_relative_line_numbers = false,
		})

		-- Diffview setup with default keymaps (desc fields for diffview's help system)
		local actions = require("diffview.actions")

		-- Helper to register which-key descriptions for diff view buffers
		local function register_diffview_whichkey(bufnr)
			local ok, wk = pcall(require, "which-key")
			if not ok then
				return
			end
			wk.add({
				{ "<tab>", desc = "Next file diff", buffer = bufnr },
				{ "<s-tab>", desc = "Previous file diff", buffer = bufnr },
				{ "gf", desc = "Open file in previous tab", buffer = bufnr },
				{ "g<C-x>", desc = "Cycle layout", buffer = bufnr },
				{ "[x", desc = "Previous conflict", buffer = bufnr },
				{ "]x", desc = "Next conflict", buffer = bufnr },
				{ "<leader>b", desc = "Toggle file panel", buffer = bufnr },
				{ "<leader>e", desc = "Focus file panel", buffer = bufnr },
				{ "<leader>c", group = "conflict resolution", buffer = bufnr },
				{ "<leader>co", desc = "Choose OURS", buffer = bufnr },
				{ "<leader>ct", desc = "Choose THEIRS", buffer = bufnr },
				{ "<leader>cb", desc = "Choose BASE", buffer = bufnr },
				{ "<leader>ca", desc = "Choose ALL", buffer = bufnr },
				{ "<leader>cO", desc = "Choose OURS (all)", buffer = bufnr },
				{ "<leader>cT", desc = "Choose THEIRS (all)", buffer = bufnr },
				{ "<leader>cB", desc = "Choose BASE (all)", buffer = bufnr },
				{ "<leader>cA", desc = "Choose ALL (all)", buffer = bufnr },
				{ "dx", desc = "Delete conflict region", buffer = bufnr },
				{ "dX", desc = "Delete all conflict regions", buffer = bufnr },
			})
		end

		require("diffview").setup({
			hooks = {
				diff_buf_win_enter = function(bufnr)
					register_diffview_whichkey(bufnr)
				end,
			},
			keymaps = {
				view = {
					{ "n", "<tab>", actions.select_next_entry, { desc = "Next file diff" } },
					{ "n", "<s-tab>", actions.select_prev_entry, { desc = "Previous file diff" } },
					{ "n", "gf", actions.goto_file_edit, { desc = "Open file in previous tab" } },
					{ "n", "<C-w><C-f>", actions.goto_file_split, { desc = "Open file in split" } },
					{ "n", "<C-w>gf", actions.goto_file_tab, { desc = "Open file in new tab" } },
					{ "n", "<leader>e", actions.focus_files, { desc = "Focus file panel" } },
					{ "n", "<leader>b", actions.toggle_files, { desc = "Toggle file panel" } },
					{ "n", "g<C-x>", actions.cycle_layout, { desc = "Cycle layout" } },
					{ "n", "[x", actions.prev_conflict, { desc = "Previous conflict" } },
					{ "n", "]x", actions.next_conflict, { desc = "Next conflict" } },
					{ "n", "<leader>co", actions.conflict_choose("ours"), { desc = "Choose OURS" } },
					{ "n", "<leader>ct", actions.conflict_choose("theirs"), { desc = "Choose THEIRS" } },
					{ "n", "<leader>cb", actions.conflict_choose("base"), { desc = "Choose BASE" } },
					{ "n", "<leader>ca", actions.conflict_choose("all"), { desc = "Choose ALL" } },
					{ "n", "dx", actions.conflict_choose("none"), { desc = "Delete conflict region" } },
					{
						"n",
						"<leader>cO",
						actions.conflict_choose_all("ours"),
						{ desc = "Choose OURS for all conflicts" },
					},
					{
						"n",
						"<leader>cT",
						actions.conflict_choose_all("theirs"),
						{ desc = "Choose THEIRS for all conflicts" },
					},
					{
						"n",
						"<leader>cB",
						actions.conflict_choose_all("base"),
						{ desc = "Choose BASE for all conflicts" },
					},
					{
						"n",
						"<leader>cA",
						actions.conflict_choose_all("all"),
						{ desc = "Choose ALL for all conflicts" },
					},
					{ "n", "dX", actions.conflict_choose_all("none"), { desc = "Delete all conflict regions" } },
				},
				file_panel = {
					{ "n", "j", actions.next_entry, { desc = "Next entry" } },
					{ "n", "<down>", actions.next_entry, { desc = "Next entry" } },
					{ "n", "k", actions.prev_entry, { desc = "Previous entry" } },
					{ "n", "<up>", actions.prev_entry, { desc = "Previous entry" } },
					{ "n", "<cr>", actions.select_entry, { desc = "Open diff" } },
					{ "n", "o", actions.select_entry, { desc = "Open diff" } },
					{ "n", "l", actions.select_entry, { desc = "Open diff" } },
					{ "n", "-", actions.toggle_stage_entry, { desc = "Stage/unstage" } },
					{ "n", "s", actions.toggle_stage_entry, { desc = "Stage/unstage" } },
					{ "n", "S", actions.stage_all, { desc = "Stage all" } },
					{ "n", "U", actions.unstage_all, { desc = "Unstage all" } },
					{ "n", "X", actions.restore_entry, { desc = "Restore entry" } },
					{ "n", "L", actions.open_commit_log, { desc = "Open commit log" } },
					{ "n", "zo", actions.open_fold, { desc = "Expand fold" } },
					{ "n", "h", actions.close_fold, { desc = "Collapse fold" } },
					{ "n", "zc", actions.close_fold, { desc = "Collapse fold" } },
					{ "n", "za", actions.toggle_fold, { desc = "Toggle fold" } },
					{ "n", "zR", actions.open_all_folds, { desc = "Expand all folds" } },
					{ "n", "zM", actions.close_all_folds, { desc = "Collapse all folds" } },
					{ "n", "<c-b>", actions.scroll_view(-0.25), { desc = "Scroll view up" } },
					{ "n", "<c-f>", actions.scroll_view(0.25), { desc = "Scroll view down" } },
					{ "n", "<tab>", actions.select_next_entry, { desc = "Next file diff" } },
					{ "n", "<s-tab>", actions.select_prev_entry, { desc = "Previous file diff" } },
					{ "n", "gf", actions.goto_file_edit, { desc = "Open file in previous tab" } },
					{ "n", "<C-w><C-f>", actions.goto_file_split, { desc = "Open file in split" } },
					{ "n", "<C-w>gf", actions.goto_file_tab, { desc = "Open file in new tab" } },
					{ "n", "i", actions.listing_style, { desc = "Toggle list/tree view" } },
					{ "n", "f", actions.toggle_flatten_dirs, { desc = "Flatten empty subdirs" } },
					{ "n", "R", actions.refresh_files, { desc = "Refresh" } },
					{ "n", "<leader>e", actions.focus_files, { desc = "Focus file panel" } },
					{ "n", "<leader>b", actions.toggle_files, { desc = "Toggle file panel" } },
					{ "n", "g<C-x>", actions.cycle_layout, { desc = "Cycle layout" } },
					{ "n", "[x", actions.prev_conflict, { desc = "Previous conflict" } },
					{ "n", "]x", actions.next_conflict, { desc = "Next conflict" } },
					{ "n", "g?", actions.help("file_panel"), { desc = "Help" } },
					{
						"n",
						"<leader>cO",
						actions.conflict_choose_all("ours"),
						{ desc = "Choose OURS for all conflicts" },
					},
					{
						"n",
						"<leader>cT",
						actions.conflict_choose_all("theirs"),
						{ desc = "Choose THEIRS for all conflicts" },
					},
					{
						"n",
						"<leader>cB",
						actions.conflict_choose_all("base"),
						{ desc = "Choose BASE for all conflicts" },
					},
					{
						"n",
						"<leader>cA",
						actions.conflict_choose_all("all"),
						{ desc = "Choose ALL for all conflicts" },
					},
					{ "n", "dX", actions.conflict_choose_all("none"), { desc = "Delete all conflict regions" } },
				},
				file_history_panel = {
					{ "n", "g!", actions.options, { desc = "Open option panel" } },
					{ "n", "<C-A-d>", actions.open_in_diffview, { desc = "Open commit in diffview" } },
					{ "n", "y", actions.copy_hash, { desc = "Copy commit hash" } },
					{ "n", "L", actions.open_commit_log, { desc = "Show commit details" } },
					{ "n", "zR", actions.open_all_folds, { desc = "Expand all folds" } },
					{ "n", "zM", actions.close_all_folds, { desc = "Collapse all folds" } },
					{ "n", "j", actions.next_entry, { desc = "Next entry" } },
					{ "n", "<down>", actions.next_entry, { desc = "Next entry" } },
					{ "n", "k", actions.prev_entry, { desc = "Previous entry" } },
					{ "n", "<up>", actions.prev_entry, { desc = "Previous entry" } },
					{ "n", "<cr>", actions.select_entry, { desc = "Open diff" } },
					{ "n", "o", actions.select_entry, { desc = "Open diff" } },
					{ "n", "<2-LeftMouse>", actions.select_entry, { desc = "Open diff" } },
					{ "n", "<c-b>", actions.scroll_view(-0.25), { desc = "Scroll up" } },
					{ "n", "<c-f>", actions.scroll_view(0.25), { desc = "Scroll down" } },
					{ "n", "<tab>", actions.select_next_entry, { desc = "Next file diff" } },
					{ "n", "<s-tab>", actions.select_prev_entry, { desc = "Previous file diff" } },
					{ "n", "gf", actions.goto_file_edit, { desc = "Open file in previous tab" } },
					{ "n", "<C-w><C-f>", actions.goto_file_split, { desc = "Open file in split" } },
					{ "n", "<C-w>gf", actions.goto_file_tab, { desc = "Open file in new tab" } },
					{ "n", "<leader>e", actions.focus_files, { desc = "Focus file panel" } },
					{ "n", "<leader>b", actions.toggle_files, { desc = "Toggle file panel" } },
					{ "n", "g<C-x>", actions.cycle_layout, { desc = "Cycle layout" } },
					{ "n", "g?", actions.help("file_history_panel"), { desc = "Help" } },
				},
				option_panel = {
					{ "n", "<tab>", actions.select_entry, { desc = "Change option" } },
					{ "n", "q", actions.close, { desc = "Close panel" } },
					{ "n", "g?", actions.help("option_panel"), { desc = "Help" } },
				},
				help_panel = {
					{ "n", "q", actions.close, { desc = "Close help" } },
					{ "n", "<esc>", actions.close, { desc = "Close help" } },
				},
			},
		})

		-- Register diffview keymaps with which-key explicitly when buffers are created
		-- This ensures which-key displays them properly (similar to fzf-lua pattern)
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "DiffviewFiles", "DiffviewFileHistory" },
			callback = function()
				local wk = require("which-key")

				-- Common keymaps for both file panel and diff view
				wk.add({
					{ "<tab>", desc = "Next file diff", buffer = 0 },
					{ "<s-tab>", desc = "Previous file diff", buffer = 0 },
					{ "gf", desc = "Open file in previous tab", buffer = 0 },
					{ "g<C-x>", desc = "Cycle layout", buffer = 0 },
					{ "[x", desc = "Previous conflict", buffer = 0 },
					{ "]x", desc = "Next conflict", buffer = 0 },
					{ "<leader>b", desc = "Toggle file panel", buffer = 0 },
					{ "<leader>e", desc = "Focus file panel", buffer = 0 },
					{ "<leader>c", group = "conflict resolution", buffer = 0 },
					{ "<leader>co", desc = "Choose OURS", buffer = 0 },
					{ "<leader>ct", desc = "Choose THEIRS", buffer = 0 },
					{ "<leader>cb", desc = "Choose BASE", buffer = 0 },
					{ "<leader>ca", desc = "Choose ALL", buffer = 0 },
					{ "<leader>cO", desc = "Choose OURS (all)", buffer = 0 },
					{ "<leader>cT", desc = "Choose THEIRS (all)", buffer = 0 },
					{ "<leader>cB", desc = "Choose BASE (all)", buffer = 0 },
					{ "<leader>cA", desc = "Choose ALL (all)", buffer = 0 },
					{ "dx", desc = "Delete conflict region", buffer = 0 },
					{ "dX", desc = "Delete all conflict regions", buffer = 0 },
				})

				-- File panel specific keymaps
				local ft = vim.bo.filetype
				if ft == "DiffviewFiles" then
					wk.add({
						{ "j", desc = "Next entry", buffer = 0 },
						{ "k", desc = "Previous entry", buffer = 0 },
						{ "<cr>", desc = "Open diff", buffer = 0 },
						{ "o", desc = "Open diff", buffer = 0 },
						{ "l", desc = "Open diff", buffer = 0 },
						{ "-", desc = "Stage/unstage", buffer = 0 },
						{ "s", desc = "Stage/unstage", buffer = 0 },
						{ "S", desc = "Stage all", buffer = 0 },
						{ "U", desc = "Unstage all", buffer = 0 },
						{ "X", desc = "Restore entry", buffer = 0 },
						{ "L", desc = "Open commit log", buffer = 0 },
						{ "R", desc = "Refresh", buffer = 0 },
						{ "i", desc = "Toggle list/tree view", buffer = 0 },
						{ "f", desc = "Flatten empty subdirs", buffer = 0 },
						{ "h", desc = "Collapse fold", buffer = 0 },
						{ "zo", desc = "Expand fold", buffer = 0 },
						{ "zc", desc = "Collapse fold", buffer = 0 },
						{ "za", desc = "Toggle fold", buffer = 0 },
						{ "zR", desc = "Expand all folds", buffer = 0 },
						{ "zM", desc = "Collapse all folds", buffer = 0 },
						{ "g?", desc = "Help", buffer = 0 },
					})
				elseif ft == "DiffviewFileHistory" then
					wk.add({
						{ "j", desc = "Next entry", buffer = 0 },
						{ "k", desc = "Previous entry", buffer = 0 },
						{ "<cr>", desc = "Open diff", buffer = 0 },
						{ "o", desc = "Open diff", buffer = 0 },
						{ "y", desc = "Copy commit hash", buffer = 0 },
						{ "L", desc = "Show commit details", buffer = 0 },
						{ "g!", desc = "Open option panel", buffer = 0 },
						{ "zR", desc = "Expand all folds", buffer = 0 },
						{ "zM", desc = "Collapse all folds", buffer = 0 },
						{ "g?", desc = "Help", buffer = 0 },
					})
				end
			end,
		})

		-- Global keymaps
		vim.keymap.set("n", "<leader>gg", "<cmd>Neogit<cr>", { desc = "Open Neogit" })
		vim.keymap.set("n", "<leader>gv", "<cmd>DiffviewOpen<cr>", { desc = "Open Diffview" })
		vim.keymap.set("n", "<leader>gx", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" })
	end,
}
