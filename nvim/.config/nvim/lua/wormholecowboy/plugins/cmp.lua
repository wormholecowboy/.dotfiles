return {
	"hrsh7th/nvim-cmp",
	enabled = false,
	event = "InsertEnter",
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",
		"onsails/lspkind.nvim",
		"folke/lazydev.nvim",
	},
	config = function()
		local cmp = require("cmp")
		local lspkind = require("lspkind")
		lspkind.init({})

		cmp.setup({
			-- cmp.config is a valid nvim-cmp API (lua_ls may show false warning)
			---@diagnostic disable-next-line: undefined-field
			sources = cmp.config.sources({
				{ name = "lazydev", group_index = 0 }, -- set group index to 0 to skip loading LuaLS completions
				{ name = "nvim_lsp" },
				{ name = "buffer", keyword_length = 3 },
				{ name = "path" },
			}),
			completion = {
				completeopt = "menu,menuone,preview,noinsert",
			},
			window = {
				completion = {
					winhighlight = "Normal:Pmenu,CursorLine:PmenuSel,FloatBorder:FloatBorder,Search:None",
					col_offset = -3,
					side_padding = 1,
					scrollbar = false,
					scrolloff = 8,
				},
				documentation = {
					winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,Search:None",
				},
			},
			mapping = {
				["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
				["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
				["<C-l>"] = cmp.mapping.confirm({ select = true }),
				["<C-y>"] = cmp.mapping(
					cmp.mapping.confirm({
						behavior = cmp.ConfirmBehavior.Insert,
						select = true,
					}),
					{ "i", "c" }
				),
			},
			formatting = {
				fields = { "abbr", "kind", "menu" },
				expandable_indicator = true,
				format = lspkind.cmp_format({
					maxwidth = 50,
					ellipsis_char = "...",
					menu = {
						nvim_lsp = "lsp",
						nvim_lua = "lua",
						path = "path",
						buffer = "buf",
						treesitter = "",
						zsh = "",
						codieum = "󰚩",
					},
				}),
			},
		})
	end,
}
