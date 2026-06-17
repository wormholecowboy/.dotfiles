return {
	"nvim-treesitter/nvim-treesitter-textobjects",
	branch = "main",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("nvim-treesitter-textobjects").setup({
			select = {
				lookahead = true,
				selection_modes = {
					["@parameter.outer"] = "v",
					["@function.outer"] = "V",
					["@class.outer"] = "<c-v>",
				},
				include_surrounding_whitespace = true,
			},
			move = {
				set_jumps = true,
			},
		})

		local select = require("nvim-treesitter-textobjects.select")
		local move = require("nvim-treesitter-textobjects.move")

		local select_map = {
			["af"] = "@function.outer",
			["if"] = "@function.inner",
			["ac"] = "@class.outer",
			["ic"] = "@class.inner",
			["ii"] = "@conditional.inner",
			["ai"] = "@conditional.outer",
			["il"] = "@loop.inner",
			["al"] = "@loop.outer",
			["at"] = "@comment.outer",
		}
		for lhs, query in pairs(select_map) do
			vim.keymap.set({ "x", "o" }, lhs, function()
				select.select_textobject(query, "textobjects")
			end, { desc = "Select " .. query })
		end

		local function move_set(mode, mappings, fn)
			for lhs, query in pairs(mappings) do
				vim.keymap.set({ "n", "x", "o" }, lhs, function()
					fn(query, "textobjects")
				end, { desc = mode .. " " .. query })
			end
		end

		move_set("goto_next_start", {
			["]m"] = "@function.outer",
			["]]"] = "@class.outer",
		}, move.goto_next_start)

		move_set("goto_next_end", {
			["]M"] = "@function.outer",
			["]["] = "@class.outer",
		}, move.goto_next_end)

		move_set("goto_previous_start", {
			["[m"] = "@function.outer",
			["[["] = "@class.outer",
		}, move.goto_previous_start)

		move_set("goto_previous_end", {
			["[M"] = "@function.outer",
			["[]"] = "@class.outer",
		}, move.goto_previous_end)
	end,
}
