return {
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
  },
  keys = {
    -- <c-h/j/k/l> handled by vim-herdr-navigation (after/plugin/herdr-nav.lua),
    -- which falls back to these TmuxNavigate commands under $TMUX
    { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
  },
  init = function()
    vim.g.tmux_navigator_no_mappings = 1
  end,
}
