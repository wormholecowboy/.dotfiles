return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
		-- Adapters
		"nvim-neotest/neotest-python",
		"nvim-neotest/neotest-jest",
		"fredrikaverpil/neotest-golang",
	},
	keys = {
		{
			"<F3>n",
			function()
				require("neotest").run.run()
			end,
			desc = "nearest test",
		},
		{
			"<F3>f",
			function()
				require("neotest").run.run(vim.fn.expand("%"))
			end,
			desc = "file tests",
		},
		{
			"<F3>p",
			function()
				require("neotest").run.run(vim.fn.getcwd())
			end,
			desc = "project tests",
		},
		{
			"<F3>l",
			function()
				require("neotest").run.run_last()
			end,
			desc = "last test",
		},
		{
			"<F3>s",
			function()
				require("neotest").summary.toggle()
			end,
			desc = "toggle summary",
		},
		{
			"<F3>o",
			function()
				require("neotest").output.open({ enter = true })
			end,
			desc = "output window",
		},
		{
			"<F3>O",
			function()
				require("neotest").output_panel.toggle()
			end,
			desc = "output panel",
		},
		{
			"<F3>x",
			function()
				require("neotest").run.stop()
			end,
			desc = "stop tests",
		},
		{
			"<F3>w",
			function()
				require("neotest").watch.toggle(vim.fn.expand("%"))
			end,
			desc = "watch file",
		},
		{
			"[t",
			function()
				require("neotest").jump.prev({ status = "failed" })
			end,
			desc = "prev failed test",
		},
		{
			"]t",
			function()
				require("neotest").jump.next({ status = "failed" })
			end,
			desc = "next failed test",
		},
	},
	config = function()
		require("neotest").setup({
			adapters = {
				require("neotest-python")({
					dap = { justMyCode = false },
					runner = "pytest",
					python = "python", -- uses virtual env if active
					pytest_discover_instances = true,
				}),
				require("neotest-jest")({
					jestCommand = function()
						local file = vim.fn.expand("%:p")
						local root = vim.fn.fnamemodify(file, ":h")
						-- Walk up to find package.json
						while root ~= "/" do
							local pkg = root .. "/package.json"
							if vim.fn.filereadable(pkg) == 1 then
								local content = vim.fn.readfile(pkg)
								local json = table.concat(content, "")
								-- Check if it's a CRA project (has react-scripts)
								if json:find("react%-scripts") then
									return "npm test --"
								end
								-- Check for direct jest dependency
								if json:find('"jest"') then
									return "npx jest"
								end
							end
							root = vim.fn.fnamemodify(root, ":h")
						end
						return "npx jest"
					end,
					jestConfigFile = function()
						local file = vim.fn.expand("%:p")
						local root = vim.fn.fnamemodify(file, ":h")
						while root ~= "/" do
							for _, name in ipairs({ "jest.config.js", "jest.config.ts", "jest.config.mjs" }) do
								if vim.fn.filereadable(root .. "/" .. name) == 1 then
									return root .. "/" .. name
								end
							end
							-- CRA doesn't need a jest config file
							local pkg = root .. "/package.json"
							if vim.fn.filereadable(pkg) == 1 then
								local content = table.concat(vim.fn.readfile(pkg), "")
								if content:find("react%-scripts") then
									return nil
								end
							end
							root = vim.fn.fnamemodify(root, ":h")
						end
						return nil
					end,
					env = { CI = true },
					cwd = function()
						return vim.fn.getcwd()
					end,
				}),
				require("neotest-golang")({
					go_test_args = { "-v", "-race", "-count=1", "-timeout=60s" },
				}),
			},
			status = {
				virtual_text = true,
				signs = true,
			},
			output = {
				enabled = true,
				open_on_run = false,
			},
			quickfix = {
				enabled = true,
				open = false,
			},
			summary = {
				animated = true,
				enabled = true,
				expand_errors = true,
				follow = true,
				mappings = {
					attach = "a",
					clear_marked = "M",
					clear_target = "T",
					debug = "d",
					debug_marked = "D",
					expand = { "<CR>", "<2-LeftMouse>" },
					expand_all = "e",
					jumpto = "i",
					mark = "m",
					next_failed = "J",
					output = "o",
					prev_failed = "K",
					run = "r",
					run_marked = "R",
					short = "O",
					stop = "u",
					target = "t",
					watch = "w",
				},
			},
			icons = {
				passed = "✓",
				failed = "✗",
				running = "⟳",
				skipped = "○",
				unknown = "?",
			},
		})
	end,
}
