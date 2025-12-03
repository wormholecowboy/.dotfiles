return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
	keys = {
		{
			",g",
			function()
				require("harpoon"):list():add()
			end,
			desc = "add file",
		},
		{
			"<M-h>",
			function()
				local harpoon = require("harpoon")
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end,
			desc = "harpoon menu",
		},
		{
			",a",
			function()
				require("harpoon"):list():select(1)
			end,
			desc = "file 1",
		},
		{
			",s",
			function()
				require("harpoon"):list():select(2)
			end,
			desc = "file 2",
		},
		{
			",d",
			function()
				require("harpoon"):list():select(3)
			end,
			desc = "file 3",
		},
		{
			",f",
			function()
				require("harpoon"):list():select(4)
			end,
			desc = "file 4",
		},
		{
			",q",
			function()
				require("harpoon"):list():select(5)
			end,
			desc = "file 5",
		},
		{
			",w",
			function()
				require("harpoon"):list():select(6)
			end,
			desc = "file 6",
		},
	},
	config = function()
		require("harpoon"):setup()
	end,
}
