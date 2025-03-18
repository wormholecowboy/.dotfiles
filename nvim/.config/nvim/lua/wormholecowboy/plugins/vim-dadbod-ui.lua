return {
	"kristijanhusak/vim-dadbod-ui",
	dependencies = {
		{ "tpope/vim-dadbod", lazy = true },
		{ "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
	},
	cmd = {
		"DBUI",
		"DBUIToggle",
		"DBUIAddConnection",
		"DBUIFindBuffer",
	},
	init = function()
		-- Your DBUI configuration
		vim.g.db_ui_use_nerd_fonts = 1

		vim.g.dbs = {
			stagePublic = os.getenv("DBUI_STAGEPUBLIC"),
			-- prodPublic = os.getenv("DBUI_PRODPUBLIC"),
			-- stageGeneral = os.getenv("DBUI_STAGEGENERAL"),
			-- prodGeneral = os.getenv("DBUI_PRODGENERAL"),
		}

    vim.keymap.set("n", "<leader>db", ":DBUIToggle<cr>", {})
	end,
}
