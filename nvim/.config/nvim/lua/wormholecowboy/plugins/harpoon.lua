return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
	config = function()
		local harpoon = require("harpoon")
		harpoon:setup()

		vim.keymap.set("n", ",g", function()
			harpoon:list():add()
		end)
		vim.keymap.set("n", "<M-h>", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end)

		vim.keymap.set("n", ",a", function()
			harpoon:list():select(1)
		end)
		vim.keymap.set("n", ",s", function()
			harpoon:list():select(2)
		end)
		vim.keymap.set("n", ",d", function()
			harpoon:list():select(3)
		end)
		vim.keymap.set("n", ",f", function()
			harpoon:list():select(4)
		end)
		vim.keymap.set("n", ",q", function()
			harpoon:list():select(5)
		end)

	end,
}
