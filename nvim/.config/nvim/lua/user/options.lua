-- :help options
vim.opt.clipboard = "unnamedplus" -- allows neovim to access the system clipboard
vim.opt.fileencoding = "utf-8" -- the encoding written to a file
vim.opt.ignorecase = true -- ignore case in search patterns
vim.opt.pumheight = 10 -- pop up menu height
-- vim.opt.smartindent = true -- make indenting smarter again

vim.opt.splitbelow = true -- force all horizontal splits to go below current window
vim.opt.splitright = true -- force all vertical splits to go to the right of current window
vim.opt.termguicolors = true -- set term gui colors (most terminals support this)

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.expandtab = true -- convert tabs to spaces
vim.opt.shiftwidth = 4 -- the number of spaces inserted for each indentation
vim.opt.tabstop = 4 -- insert 4 spaces for a tab
vim.opt.softtabstop = 4
vim.opt.numberwidth = 4 -- set number column width to 2 {default 4}
vim.opt.scrolloff = 8 -- is one of my fav
vim.opt.sidescrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.cursorline = true -- highlight the current line
vim.opt.number = true -- set numbered lines
vim.opt.relativenumber = true
vim.opt.wrap = false -- display lines as one long line

vim.opt.updatetime = 50

vim.opt.colorcolumn = "80"
