-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"
local keymap = vim.keymap.set
local opts = { silent = true }
-- add your own keymapping
keymap("n", "<TAB>", ":bnext<CR>", opts)
keymap("n", "<S-TAB>", ":bprevious<CR>", opts)
keymap("n", "<leader><leader>z", ":Goyo<CR>", opts)
-- unmap a default keymapping
-- vim.keymap.del("n", "<C-Up>")
-- override a default keymapping
-- lvim.keys.normal_mode["<C-q>"] = ":q<cr>" -- or vim.keymap.set("n", "<C-q>", ":q<cr>" )
