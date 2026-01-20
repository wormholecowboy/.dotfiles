-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║                            KEYMAP LEGEND                                 ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
--
-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │ NAVIGATION & MOTIONS                                                    │
-- ├──────────────┬──────────────────────────────────────────────────────────┤
-- │ s / S        │ leap forward / cross-window (leap.nvim)                  │
-- │ H / L        │ prev / next buffer                                       │
-- │ [b / ]b      │ move buffer left / right                                 │
-- │ [d / ]d      │ prev / next diagnostic                                   │
-- │ [c / ]c      │ prev / next git change                                   │
-- │ [t / ]t      │ prev / next failed test                                  │
-- │ { / }        │ prev / next aerial symbol                                │
-- └──────────────┴──────────────────────────────────────────────────────────┘
--
-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │ g PREFIX — LSP & MISC                                                   │
-- ├──────────────┬──────────────────────────────────────────────────────────┤
-- │ gd           │ go to definition                                         │
-- │ gD           │ go to declaration                                        │
-- │ gi           │ go to implementation                                     │
-- │ gt           │ go to type definition                                    │
-- │ go           │ go to definition of type                                 │
-- │ gr           │ go to references                                         │
-- │ gs           │ signature help                                           │
-- │ gl           │ show diagnostic float                                    │
-- │ gP           │ select last paste                                        │
-- │ gb / gc      │ comment operators (comment.nvim)                         │
-- └──────────────┴──────────────────────────────────────────────────────────┘
--
-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │ <leader> PREFIX                                                         │
-- ├──────────────┬──────────────────────────────────────────────────────────┤
-- │ o / O        │ add blank line below / above                             │
-- │ A            │ copy all (yank entire buffer)                            │
-- │ c            │ close buffer                                             │
-- │ e            │ file explorer (oil.nvim)                                 │
-- │ i            │ toggle indent lines                                      │
-- │ m            │ markdown preview                                         │
-- │ t            │ toggle aerial (code outline)                             │
-- │ w            │ write (save)                                             │
-- │ z            │ zen mode                                                 │
-- ├──────────────┼──────────────────────────────────────────────────────────┤
-- │ a            │ Reserved for AI                                          │
-- ├──────────────┼──────────────────────────────────────────────────────────┤
-- │ g            │ +git                                                     │
-- │   g          │   neogit status                                          │
-- │   v          │   diffview                                               │
-- │   w          │   worktree switch                                        │
-- │   cw         │   worktree create                                        │
-- │   x          │   close diffview                                         │
-- ├──────────────┼──────────────────────────────────────────────────────────┤
-- │ h            │ +hunks (gitsigns)                                        │
-- ├──────────────┼──────────────────────────────────────────────────────────┤
-- │ l            │ +lint/log                                                │
-- │   l          │   lint file                                              │
-- │   v          │   log variable                                           │
-- ├──────────────┼──────────────────────────────────────────────────────────┤
-- │ s            │ +search (fzf-lua)                                        │
-- ├──────────────┼──────────────────────────────────────────────────────────┤
-- │ u            │ +user                                                    │
-- │   b          │   buffer path                                            │
-- │   c          │   code actions                                           │
-- │   d          │   insert date                                            │
-- │   i          │   open IDE (vscode forks)                                │
-- │   n          │   notes                                                  │
-- │   p          │   prog notes                                             │
-- │   t          │   twilight                                               │
-- │   v          │   edit nvim config                                       │
-- │   x          │   close split buffer                                     │
-- │   z          │   edit zshrc                                             │
-- │   w          │   +workspace (LSP)                                       │
-- │     a        │     add folder                                           │
-- │     l        │     list folders                                         │
-- │     r        │     remove folder                                        │
-- └──────────────┴──────────────────────────────────────────────────────────┘
--
-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │ HARPOON (comma prefix)                                                  │
-- ├──────────────┬──────────────────────────────────────────────────────────┤
-- │ ,            │ harpoon commands (see harpoon.lua)                       │
-- │ <C-h>        │ harpoon list                                             │
-- └──────────────┴──────────────────────────────────────────────────────────┘
--
-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │ FUNCTION KEYS                                                           │
-- ├──────────────┬──────────────────────────────────────────────────────────┤
-- │ F1           │ help                                                     │
-- │ F2           │ rename                                                   │
-- │ F3           │ +test (neotest.lua)                                      │
-- │   n          │   nearest test                                           │
-- │   f          │   file tests                                             │
-- │   p          │   project tests                                          │
-- │   l          │   last test                                              │
-- │   s          │   toggle summary                                         │
-- │   o          │   output window                                          │
-- │   O          │   output panel                                           │
-- │   x          │   stop tests                                             │
-- │   w          │   watch file                                             │
-- │ F6           │ format code (conform.lua)                                │
-- │ F7           │ trouble diagnostics (trouble.lua)                        │
-- │ F8           │ lint (nvim-lint.lua)                                     │
-- └──────────────┴──────────────────────────────────────────────────────────┘
--
-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │ MODIFIER KEYS                                                           │
-- ├──────────────┬──────────────────────────────────────────────────────────┤
-- │ <C-e>        │ insert emoji (insert mode)                               │
-- │ <M-c>        │ color picker (ccc.nvim)                                  │
-- │ <C-h/j/k/l>  │ window navigation                                        │
-- └──────────────┴──────────────────────────────────────────────────────────┘
--
-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │ DISABLED                                                                │
-- ├──────────────┬──────────────────────────────────────────────────────────┤
-- │ Q            │ disabled (nop)                                           │
-- │ <C-z>        │ disabled (nop)                                           │
-- └──────────────┴──────────────────────────────────────────────────────────┘

local keymap = vim.keymap.set
local opts = { silent = true }

vim.g.mapleader = " "

keymap("i", "kj", "<ESC>", opts) -- alt escape
keymap("v", "kj", "<ESC>", opts) -- alt escape
vim.api.nvim_set_keymap("n", "QQ", ":q!<enter>", { noremap = false }) -- quit nv

-- Kill these
keymap("n", "Q", "<nop>")
keymap("n", "<C-z>", "<nop>")
-- Better pasting
keymap("x", "p", [["_dP]])
keymap("n", "r", [["_r]])
keymap("n", "x", [["_x]])
-- keymap("n", "s", [["_s]]) -- disabled: leap.nvim uses 's' for forward motion
keymap("n", "c", [["_c]])

-- For WSL
-- function removeReturnCharacters()
--   vim.cmd("%s/\r$//")
-- end

keymap("n", "<leader>uz", "<cmd>edit $HOME/.zshrc<cr>", opts) --edit zsh
keymap("n", "<leader>uv", "<cmd>edit $HOME/.config/nvim/<cr>", opts) --edit neovim
keymap("n", "<leader>up", "<cmd>edit $HOME/pnotes<cr>", opts) --prog notes
-- <leader>uc is set in lspconfig.lua on LspAttach (buffer-local)
-- keymap("n", "<leader>uw", "`[v`]:lua removeReturnCharacters()<cr>", opts) --remove windows return carriage for WSL
keymap("n", "<leader>ud", "<cmd>r !date '+\\%Y-\\%m-\\%d'<CR>", opts)  -- date

keymap("n", "<leader>w", ":w<cr>", opts) --save
keymap("n", "<leader>c", ":bp|bd#<cr>", opts) --close split buffer
keymap("n", "<leader>A", ":%y+<cr>", opts) --select all
keymap("n", "gP", "`[v`]", opts) --select last paste
-- keymap("n", "<leader>q", "<cmd>lua require('cmp').setup.buffer { enabled = false }<cr>", opts) --quiet
-- keymap("n", "<leader>r", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])  --dumb rename

keymap("n", "<leader>o", "o<Esc>k", opts)
keymap("n", "<leader>O", "O<Esc>j", opts)

-- Normal --
-- Window navigation handled by vim-tmux-navigator (tmux-navigator.lua)

-- Resize with arrows
keymap("n", "<C-Up>", ":resize -2<CR>", opts)
keymap("n", "<C-Down>", ":resize +2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Navigate buffers
keymap("n", "L", ":bnext<CR>", opts)
keymap("n", "H", ":bprevious<CR>", opts)

-- Visual --
-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move text up and down
keymap("n", "<A-j>", "<Esc>:m .+1<CR>==gi", opts)
keymap("n", "<A-k>", "<Esc>:m .-2<CR>==gi", opts)

-- Visual Block --
-- Move text up and down
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)
keymap("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
keymap("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)

-- vim.keymap.set("n", "J", "mzJ`z") This keeps the cursor in the same spot for "J"
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv") -- These 2 keep your cursor in the middle on search
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "*", "*zz")
vim.keymap.set("n", "#", "#zz")

-- this is for switching projects with tmux?
-- vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

-- This is for the quickfix list
-- vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
-- vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
-- vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
-- vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- make a file executable
-- vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
