return {
	"martinsione/darkplus.nvim",
	dependencies = {
		"neanias/everforest-nvim",
		"morhetz/gruvbox",
		"EdenEast/nightfox.nvim",
		"kvrohit/mellow.nvim",
		"talha-akram/noctis.nvim",
    "whatyouhide/vim-gotham",
    "toupeira/vim-desertink",
    "tomasr/molokai",
    "ayu-theme/ayu-vim",
    "AlessandroYorba/Alduin",
    "chase/focuspoint-vim",
    "yorickpeterse/happy_hacking.vim"
	},
	config = function()
		function ColorMyPencils(color)
			color = color or "focuspoint"
			vim.cmd.colorscheme(color)

			-- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
			-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
		end

		ColorMyPencils()

		require("everforest").setup({
			-- background = "soft",
			-- transparent_background_level = 50,
			italics = true,
			disable_italic_comments = false,
			---The contrast of line numbers, indent lines, etc. Options are `"high"` or
			---`"low"` (default).
			ui_contrast = "high",
			diagnostic_text_highlight = false,
			---Which colour the diagnostic text should be. Options are `"grey"` or `"coloured"` (default)
			diagnostic_virtual_text = "coloured",
			---Some plugins support highlighting error/warning/info/hint lines, but this
			---feature is disabled by default in this colour scheme.
			diagnostic_line_highlight = false,
		})

		vim.g.solarized_italic_comments = true
		vim.g.solarized_italic_keywords = true
		vim.g.solarized_italic_functions = true
		vim.g.solarized_italic_variables = false
		vim.g.solarized_contrast = true
		vim.g.solarized_borders = false
		vim.g.solarized_disable_background = false
	end,
}
