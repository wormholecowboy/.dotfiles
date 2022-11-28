local status_ok, goyo = pcall(require, "goyo")
if not status_ok then
	return
end
--This is not working below
goyo.setup({

	vim.api.nvim_create_autocmd("User", {
		pattern = "GoyoEnter",
		callback = function()
			vim.opt.wrap = true
			vim.opt.linebreak = true
			vim.opt.spell = false
			vim.opt.spelllang = "en_us"
			require("lualine").hide()
			require("cmp").setup.buffer({ enabled = false })
		end,
	}),

	vim.api.nvim_create_autocmd("User", {
		pattern = "GoyoLeave",
		callback = function()
			vim.opt.linebreak = false
			vim.opt.wrap = false
			require("lualine").hide({ unhide = true })
			require("cmp").setup.buffer({ enabled = true })
		end,
	}),
})
