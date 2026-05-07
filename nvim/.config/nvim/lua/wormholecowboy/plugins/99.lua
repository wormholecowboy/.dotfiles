return {
	"ThePrimeagen/99",
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
