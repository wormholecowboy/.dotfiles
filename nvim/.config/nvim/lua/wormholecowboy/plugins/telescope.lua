return {

  "nvim-telescope/telescope.nvim",
  version = "0.1.2",
  dependencies = { { "nvim-lua/plenary.nvim" } },
  config = function()
    local status_ok, telescope = pcall(require, "telescope")
    if not status_ok then
      return
    end

    local actions = require("telescope.actions")
    local builtin = require("telescope.builtin")

    function searchString()
      builtin.grep_string({ search = vim.fn.input("Grep > ") })
    end

    local wk = require("which-key")
    wk.register({
      s = {
        a = { "<cmd>Telescope autocommands<cr>", "man pages" },
        b = { "<cmd>Telescope buffers<cr>", "buffer" },
        cc = { "<cmd>Telescope commands<cr>", "commands" },
        ch = { "<cmd>Telescope command_history<cr>", "command_history" },
        cs = { "<cmd>Telescope colorscheme<cr>", "color scheme" },
        f = { "<cmd>Telescope find_files<cr>", "files" },
        gb = { "<cmd>Telescope git_branches<cr>", "git branches" },
        gc = { "<cmd>Telescope git_commits<cr>", "git commits" },
        gf = { "<cmd>Telescope git_files<cr>", "git files" },
        gs = { "<cmd>Telescope git_status<cr>", "git status" },
        h = { "<cmd>Telescope help_tags<cr>", "help" },
        k = { "<cmd>Telescope keymaps<cr>", "keymaps" },
        m = { "<cmd>Telescope marks<cr>", "marks" },
        n = { "<cmd>Telescope man_pages<cr>", "man pages" },
        r = { "<cmd>Telescope oldfiles<cr>", "recent" },
        s = { "<cmd>lua searchString()<cr>", "string" },
      },
    }, { prefix = "<leader>" })

    telescope.setup({
      defaults = {

        prompt_prefix = " ",
        selection_caret = " ",
        path_display = { "smart" },
        file_ignore_patterns = { "node_modules" },
        layout_config = {
          horizontal = {
            preview_cutoff = 0,
          },
        },
        mappings = {
          i = {
            ["<Down>"] = actions.cycle_history_next,
            ["<Up>"] = actions.cycle_history_prev,
            ["<C-j>"] = actions.preview_scrolling_down,
            ["<C-k>"] = actions.preview_scrolling_up,
            ["<C-v>"] = actions.select_vertical,
            ["<C-h>"] = actions.select_horizontal,
          },
        },
      },
    })
  end,
}
