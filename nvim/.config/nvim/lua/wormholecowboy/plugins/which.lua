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
      -- Groups only - individual keys get desc from their plugin keys spec
      { "<leader>a", group = "ai" },
      { "<leader>g", group = "git" },
      { "<leader>gc", group = "create" },
      { "<leader>h", group = "hunks" },
      { "<leader>l", group = "lint/log" },
      { "<leader>s", group = "search" },
      { "<leader>sc", group = "commands" },
      { "<leader>sg", group = "git search" },
      { "<leader>u", group = "user" },
      { "<leader>uw", group = "workspace" },
      { "<F3>", group = "test" },
      { ",", group = "harpoon" },
      { "[", group = "prev" },
      { "]", group = "next" },

      -- Keymaps from keymaps.lua (no desc in their definition)
      { "<leader>A", desc = "copy all" },
      { "<leader>c", desc = "close buffer" },
      { "<leader>o", desc = "line below" },
      { "<leader>O", desc = "line above" },
      { "<leader>w", desc = "save" },
    },
  },
}
