local status_ok, telescope = pcall(require, "telescope")
if not status_ok then
    return
end

local actions = require "telescope.actions"
local builtin = require "telescope.builtin"

vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.git_files, {})
vim.keymap.set('n', '<leader>fs', function()
    builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set("n", "<leader>fp", "<cmd>Telescope projects<cr>", opts)

-- telescope.setup {
--   defaults = {
--
--     prompt_prefix = " ",
--     selection_caret = " ",
--     path_display = { "smart" },
--     file_ignore_patterns = {},
--
--     mappings = {
--       i = {
--         ["<Down>"] = actions.cycle_history_next,
--         ["<Up>"] = actions.cycle_history_prev,
--         ["<C-j>"] = actions.move_selection_next,
--         ["<C-k>"] = actions.move_selection_previous,
--         ["<C-f>"] = "which_key"
--       },
--     },
--   },
-- }
