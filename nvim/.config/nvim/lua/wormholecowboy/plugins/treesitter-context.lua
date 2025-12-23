return {
	"nvim-treesitter/nvim-treesitter-context",
	enabled = false, -- Disabled due to bash injection query issues in markdown
	event = { "BufReadPre", "BufNewFile" },
	opts = { mode = "cursor" },
	config = function(_, opts)
		require("treesitter-context").setup({
			enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
			multiwindow = false, -- Enable multiwindow support.
			max_lines = 4, -- Limit context to 4 lines to prevent consuming screen in deeply nested code
			min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
			line_numbers = true,
			multiline_threshold = 6, -- Maximum number of lines to show for a single context
			trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
			mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
			-- Separator between context and content. Should be a single character string, like '-'.
			-- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
			separator = nil,
			zindex = 20, -- The Z-index of the context window
			on_attach = function(buf)
				-- Disable for markdown due to bash injection query issues
				local ft = vim.bo[buf].filetype
				return ft ~= "markdown"
			end,
		})
	end,
}
