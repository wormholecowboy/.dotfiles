return {
	dir = vim.fn.expand("$HOME/things/myc/99/master"),
	keys = {
		{
			"<leader>av",
			function()
				require("99").visual()
			end,
			mode = "v",
			desc = "99: replace selection w/ AI",
		},
		{
			"<leader>as",
			function()
				require("99").search()
			end,
			desc = "99: search",
		},
		{
			"<leader>ax",
			function()
				require("99").stop_all_requests()
			end,
			desc = "99: stop requests",
		},
		{
			"<leader>at",
			function()
				require("99").tutorial()
			end,
			desc = "99: tutorial",
		},
		{
			"<leader>aV",
			function()
				require("99").vibe()
			end,
			desc = "99: vibe",
		},
		{
			"<leader>ao",
			function()
				require("99").open()
			end,
			desc = "99: reopen last result",
		},
		{
			"<leader>am",
			function()
				require("99.extensions.telescope").select_model()
			end,
			desc = "99: select model",
		},
		{
			"<leader>ap",
			function()
				require("99.extensions.telescope").select_provider()
			end,
			desc = "99: select provider",
		},
	},
	config = function()
		local _99 = require("99")
		_99.setup({
			provider = _99.Providers.ClaudeCodeProvider,
			-- "opus" is a claude-CLI alias that always resolves to the latest Opus.
			-- Switch interactively via require("99.extensions.telescope").select_model()
			model = "opus",
		})
	end,
}
