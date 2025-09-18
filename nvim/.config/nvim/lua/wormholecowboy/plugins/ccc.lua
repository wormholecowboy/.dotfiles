return {

	"uga-rosa/ccc.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local ccc = require("ccc")
		local mapping = ccc.mapping

		ccc.setup({
			highlighter = {
				auto_enable = true,
				lsp = true,
			},
			inputs = {
				ccc.input.rgb,
				ccc.input.hsl,
				ccc.input.cmyk,
			},
		})

    vim.keymap.set("n", "<M-c>", ":CccPick<CR>")
	end,

  -- Default mappings
  -- q cancel
  -- i change input
  -- o change output
  -- use numpad to jump quick across
  -- left and right: hl, sd, m,
  -- g toggle recent colors
  -- w b navigate recent colors
  -- a toggle alpha channel
}
