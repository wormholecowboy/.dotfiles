-- nvim-treesitter `main` branch API (NOT the old `master` `configs.setup` API):
--   * `setup()` only takes `install_dir`; default is stdpath("data")/site, which
--     is already on the runtimepath, so we don't need to override it.
--   * `install()` is what copies each language's parser AND its queries into that
--     dir. Without it, parsers may exist but the highlights query is never found,
--     so `vim.treesitter.start()` runs and paints nothing.
--   * Highlighting is enabled by the FileType autocmd in core/autocommands.lua
--     (`vim.treesitter.start()`), per the plugin docs.
local ensure = {
	"javascript",
	"typescript",
	"c",
	"lua",
	"vim",
	"vimdoc",
	"query",
	"java",
	"jq",
	"dockerfile",
	"json",
	"html",
	"terraform",
	"go",
	"tsx",
	"bash",
	"ruby",
	"markdown",
	"python",
}

return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		-- `main` branch compiles parsers with the `tree-sitter` CLI (separate from
		-- the libtree-sitter brew formula). Without it, install() fails to build
		-- parsers, their queries never get copied to the rtp, and highlighting
		-- silently dies. Alert loudly instead of failing quietly.
		if vim.fn.executable("tree-sitter") == 0 then
			vim.schedule(function()
				vim.notify(
					"nvim-treesitter: `tree-sitter` CLI not found on PATH.\n"
						.. "Parsers cannot compile and highlighting will break.\n"
						.. "Install it: brew install tree-sitter-cli",
					vim.log.levels.ERROR,
					{ title = "Treesitter" }
				)
			end)
			return
		end
		require("nvim-treesitter").install(ensure)
	end,
}
