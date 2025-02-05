-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

local keymap = vim.keymap.set
local opts = { silent = true }

-- add function: kill cmp, set wrap with not word breakage, turn off line hl, turn off line numbers
-- or maybe an autocommand that hooks into when a txt file or md file is opened

vim.g.mapleader = " "

-- []:
--    d: diagnostics
--    c: git changes
--    b: buffer moving
--
-- g: lsp
--      gd: def
--      gD: declaration
--      gi: implemntation
--      go: def of type
--      gr: ref
--      gs: signature
--      gl: show diagnostic
--      gP: select last paste
--      gp: goto-preview
--        d: def
--        i: impplemtation
--        D: declare
--        t: type
--        r: references
--        c: close all
--      gb and gc : comment.nvim
--
--  LEADER: my current leader remaps legend
-- o&O: add lines
-- A: copy all
-- a: ai
--    a: see avente settings
--    e:
-- c: close
-- d: debug
-- D: diagnostic
-- e: file tree
-- f: hop
-- gg: fugitive
--      ,.: diffget
--      a: add all
--      m: add all modified -u
--      p: push
--      v: Gvdiffsplit!
--      w: worktree
-- h and t: git hunks
--      check git signs for keymaps
-- m: markdown
-- q: kill cmp
-- r: rename
-- s: search files, git, string, help
-- t: aerial (tree)
-- u: user
--      b: buffer path
--      c: code actions
--      d: Noice dismiss
--      f: format
--      n: notes
--      p: prog notes
--      t: twilight
--      v: edit vim config
--      w: format wsl paste
--      x: close split buffer
--      z: edit zsh
-- U: Undotree
-- w: write
-- z: zen mode
--
-- <leader>
--    y: yank for icons
--    i: insert icon in normal mode
--<control key|
--    e: insert icon in insert mode

-- keymap("i", "kj", "<ESC>", opts)
vim.api.nvim_set_keymap("n", "QQ", ":q!<enter>", { noremap = false })

keymap("n", "Q", "<nop>")
keymap("n", "<C-z>", "<nop>")
keymap("x", "p", [["_dP]]) -- better paste
keymap("n", "r", [["_r]])
keymap("n", "x", [["_x]])
keymap("n", "s", [["_s]])
keymap("n", "c", [["_c]])

function removeReturnCharacters()
  vim.cmd("%s/\r$//")
end

keymap("n", "<leader>uz", "<cmd>edit $HOME/.zshrc<cr>", opts) --edit zsh
keymap("n", "<leader>uv", "<cmd>edit $HOME/.config/nvim/<cr>", opts) --edit neovim
keymap("n", "<leader>up", "<cmd>edit $HOME/pnotes<cr>", opts) --prog notes
keymap("n", "<leader>uc", ":lua vim.lsp.buf.code_action()<CR>", opts) --code action
keymap("n", "<leader>uw", "`[v`]:lua removeReturnCharacters()<cr>", opts) --remove windows return carriage
keymap("n", "<leader>ux", "<cmd>bp|bd #<cr>", opts) --split buf delete

keymap("n", "<leader>w", ":w<cr>", opts) --save
keymap("n", "<leader>c", ":bp|bd#<cr>", opts) --close split buffer
keymap("n", "<leader>A", ":%y+<cr>", opts) --select all
keymap("n", "gP", "`[v`]", opts) --select last paste
-- keymap("n", "<leader>q", "<cmd>lua require('cmp').setup.buffer { enabled = false }<cr>", opts) --quiet
-- keymap("n", "<leader>r", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])  --dumb rename

keymap("n", "<leader>o", "o<Esc>k", opts)
keymap("n", "<leader>O", "O<Esc>j", opts)

-- Normal --
-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Resize with arrows
keymap("n", "<C-Up>", ":resize -2<CR>", opts)
keymap("n", "<C-Down>", ":resize +2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Navigate buffers
keymap("n", "<TAB>", ":bnext<CR>", opts)
keymap("n", "<S-TAB>", ":bprevious<CR>", opts)

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
