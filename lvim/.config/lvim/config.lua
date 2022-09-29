require "brian.keys"
require "brian.options"
require "brian.plugins"
require "brian.whichkey"
require "brian.telescope"
-- require "brian.icons"
-- require "brian.spectre"
-- require "brian.todo-comments"
-- require "brian.zen-mode"

--[[

lvim is the global options object

Linters should be
filled in as strings with either
a global executable or a path to
an executable
]]

-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile

-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = {
  "bash",
  "c",
  "javascript",
  "json",
  "lua",
  "python",
  "typescript",
  "tsx",
  "css",
  "rust",
  "java",
  "yaml",
}

lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enabled = true

require 'colorizer'.setup {
  'css';
  'javascript';
  'yaml';
  html = {
    mode = 'foreground';
  }
}
