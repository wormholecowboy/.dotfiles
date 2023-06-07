-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd([[packadd packer.nvim]])

return require("packer").startup(function(use)
	-- Packer can manage itself
	use("wbthomason/packer.nvim")
	use("mbbill/undotree")
    use { "kyazdani42/nvim-tree.lua", commit = "bdb6d4a25410da35bbf7ce0dbdaa8d60432bc243" }
use( 'nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'} )
	-- use("windwp/nvim-ts-autotag")
    -- folke/trouble.nvim
use {
  'nvim-telescope/telescope.nvim', tag = '0.1.1',
-- or                            , branch = '0.1.x',
  requires = { {'nvim-lua/plenary.nvim'} }
}
use ( 'tpope/vim-fugitive')
-- need prettier, comment, autotag, autopairs, trouble?, friendly snippets, webdev icons?, project? (might not need this, check primes thing) , neoscroll, goyo, 
-- customize lualine
-- go over custom kepmaps
-- highlight on yank


-- Colors
  use { "folke/tokyonight.nvim", commit = "8223c970677e4d88c9b6b6d81bda23daf11062bb" }
  use { "lunarvim/darkplus.nvim", commit = "2584cdeefc078351a79073322eb7f14d7fbb1835" }
  use { "perfectspr/dracula-vim" }
  use { "lisposter/vim-blackboard" }
  use { "kyazdani42/blue-moon" }
  use { "lifepillar/vim-solarized8" }
  use { "sainnhe/everforest" }
  use { "morhetz/gruvbox" }

  use {
  'VonHeikemen/lsp-zero.nvim',
  branch = 'v2.x',
  requires = {
    -- LSP Support
    {'neovim/nvim-lspconfig'},             -- Required
    {                                      -- Optional
      'williamboman/mason.nvim',
      run = function()
        pcall(vim.cmd, 'MasonUpdate')
      end,
    },
    {'williamboman/mason-lspconfig.nvim'}, -- Optional

    -- Autocompletion
    {'hrsh7th/nvim-cmp'},     -- Required
    {'hrsh7th/cmp-nvim-lsp'}, -- Required
    {'L3MON4D3/LuaSnip'},     -- Required
  }
}
	-- LSP
-- 	use({
-- 		"VonHeikemen/lsp-zero.nvim",
-- 		branch = "v1.x",
-- 		requires = {
-- 			-- LSP Support
-- 			{ "neovim/nvim-lspconfig" }, -- Required
-- 			{ -- Optional
-- 				"williamboman/mason.nvim",
-- 				run = function()
-- 					pcall(vim.cmd, "MasonUpdate")
-- 				end,
-- 			},
-- 			{ "williamboman/mason-lspconfig.nvim" }, -- Optional
-- 
-- 			-- Autocompletion
-- 			{ "hrsh7th/nvim-cmp" }, -- Required
-- 			{ "hrsh7th/cmp-nvim-lsp" }, -- Required
-- 			{ "hrsh7th/cmp-buffer" }, -- Optional
-- 			{ "hrsh7th/cmp-path" }, -- Optional
-- 			{ "saadparwaiz1/cmp_luasnip" }, -- Optional
-- 			{ "hrsh7th/cmp-nvim-lua" }, -- Optional
-- 
-- 			-- Snippets
-- 			{ "L3MON4D3/LuaSnip" }, -- Required
-- 			{ "rafamadriz/friendly-snippets" }, -- Optional
-- 		},
-- 	})
end)
