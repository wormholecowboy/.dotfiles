-- <C-h/j/k/l> pane/split navigation — single source of truth.
--
-- vim-herdr-navigation owns the directional maps. On each press it tries a Neovim
-- split move first; at a split edge it hands off to the surrounding multiplexer:
-- herdr ($HERDR_PANE_ID) -> herdr pane focus, else tmux ($TMUX) -> TmuxNavigate*,
-- else plain wincmd. So this one spec is correct in both herdr and tmux, on every
-- machine. vim-tmux-navigator stays as the dependency that provides TmuxNavigate*.
--
-- The plugin isn't a standard Neovim plugin (its keymaps live in editor/nvim.lua,
-- not lua/ or plugin/), so we load that file explicitly from lazy's install dir.
return {
  "christoomey/vim-tmux-navigator",
  lazy = false,
  dependencies = { "paulbkim-dev/vim-herdr-navigation" },
  init = function()
    -- Let vim-herdr-navigation own <C-h/j/k/l> instead of vim-tmux-navigator.
    vim.g.tmux_navigator_no_mappings = 1
  end,
  config = function()
    local herdr_nav = require("lazy.core.config").plugins["vim-herdr-navigation"].dir
    dofile(herdr_nav .. "/editor/nvim.lua")
    -- <C-\> = last-active tmux pane (no herdr equivalent; no-op outside tmux).
    vim.keymap.set("n", "<c-\\>", "<cmd>TmuxNavigatePrevious<cr>", { silent = true })
  end,
}
