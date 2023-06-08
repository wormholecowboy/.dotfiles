local api = require('Comment.api')
local config = require('Comment.config'):get()

vim.keymap.set('n', '<C-/>', api.toggle.linewise.current, {})
