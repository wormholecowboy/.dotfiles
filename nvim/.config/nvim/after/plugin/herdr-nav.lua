-- Seamless <C-h/j/k/l> across Neovim splits and herdr panes.
-- Maps come from the vim-herdr-navigation repo (also linked as a herdr plugin);
-- inside tmux it falls back to vim-tmux-navigator, elsewhere plain wincmd.
local nav = vim.fn.expand("~/things/myc/vim-herdr-navigation/editor/nvim.lua")
if vim.uv.fs_stat(nav) then
  dofile(nav)
end
