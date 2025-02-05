return {
	"tpope/vim-fugitive",
	config = function()
		vim.keymap.set("n", "<leader>gg", "<cmd>vertical Git<cr>")
		vim.keymap.set("n", "<leader>g,", "<cmd>diffget //2<cr>")
		vim.keymap.set("n", "<leader>g.", "<cmd>diffget //3<cr>")
		vim.keymap.set("n", "<leader>gv", "<cmd>Gvdiffsplit!<cr>")
		vim.keymap.set("n", "<leader>ga", "<cmd>G add .<cr>")
		vim.keymap.set("n", "<leader>gm", "<cmd>G add -u<cr>")
		vim.keymap.set("n", "<leader>gp", "<cmd>G push<cr>")
		vim.keymap.set("n", "<leader>gb", "<cmd>G branch -a<cr>")
	end,
	--Gvdiffsplit for conflicts
}
