return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	keys = {
		{
			"<F8>",
			function()
				require("lint").try_lint()
			end,
			desc = "lint file",
		},
	},
	config = function()
		local lint = require("lint")
		local pylint = lint.linters.pylint

		pylint.args = {
			"-f",
			"json",
			"--disable=C0111,W0311",
			"--rcfile=" .. vim.fn.expand("~/.pylintrc"),
		}

		lint.linters_by_ft = {
			python = { "pylint" },
      lua = { "luacheck" },
			-- javascript = { "eslint_d" },
			-- javascriptreact = { "eslint_d" },
			-- typescript = { "eslint_d" },
			-- typescriptreact = { "eslint_d" },
			kotlin = { "ktlint" },
			terraform = { "tflint" },
			ruby = { "standardrb" },
		}

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
		vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				lint.try_lint()
			end,
		})
	end,
}
