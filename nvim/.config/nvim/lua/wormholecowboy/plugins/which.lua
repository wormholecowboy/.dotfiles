return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "classic",
    delay = 300,
    icons = {
      breadcrumb = "»",
      separator = "➜",
      group = "+",
    },
    win = {
      border = "none",
      padding = { 1, 2 },
    },
    layout = {
      height = { min = 4, max = 25 },
      width = { min = 20, max = 50 },
      spacing = 3,
      align = "left",
    },
    plugins = {
      marks = true,
      registers = true,
      spelling = {
        enabled = true,
        suggestions = 20,
      },
      presets = {
        operators = false,
        motions = false,
        text_objects = false,
        windows = true,
        nav = false,
        z = true,
        g = true,
      },
    },
    spec = {
      -- Leader groups
      { "<leader>a", group = "ai" },
      { "<leader>g", group = "git" },
      { "<leader>h", group = "hunks" },
      { "<leader>l", group = "lint/log" },
      { "<leader>s", group = "search" },
      { "<leader>u", group = "user" },
      { "<leader>uw", group = "workspace" },

      -- Leader single keys
      { "<leader>A", desc = "copy all" },
      { "<leader>c", desc = "close buffer" },
      { "<leader>d", desc = "diagnostic float" },
      { "<leader>e", desc = "file explorer" },
      { "<leader>i", desc = "indent lines" },
      { "<leader>m", desc = "markdown preview" },
      { "<leader>o", desc = "line below" },
      { "<leader>O", desc = "line above" },
      { "<leader>r", desc = "rename" },
      { "<leader>t", desc = "code outline" },
      { "<leader>U", desc = "undotree" },
      { "<leader>w", desc = "save" },
      { "<leader>z", desc = "zen mode" },
      { "<leader>/", desc = "comment" },

      -- Harpoon
      { ",", group = "harpoon" },

      -- Brackets
      { "[", group = "prev" },
      { "]", group = "next" },
    },
  },
}
