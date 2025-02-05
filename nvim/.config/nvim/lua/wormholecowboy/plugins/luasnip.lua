return {
  "L3MON4D3/LuaSnip",
  version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
  build = "make install_jsregexp",
  dependencies = {
    "rafamadriz/friendly-snippets",
    "saadparwaiz1/cmp_luasnip",
  },
  config = function()
    require("luasnip.loaders.from_vscode").load()

    local ls = require("luasnip")

    -- kill jump points after exiting snippet
    ls.config.set_config({
      region_check_events = "InsertEnter",
      delete_check_events = "InsertLeave",
    })

    -- vim.keymap.set({ "i" }, "<C-K>", function()
    --   ls.expand()
    -- end, { silent = true })
    vim.keymap.set({ "i", "s" }, "<C-K>", function()
      ls.jump(1)
    end, { silent = true })
    vim.keymap.set({ "i", "s" }, "<C-J>", function()
      ls.jump(-1)
    end, { silent = true })

    -- vim.keymap.set({ "i", "s" }, "<C-E>", function()
    --   if ls.choice_active() then
    --     ls.change_choice(1)
    --   end
    -- end, { silent = true })
  end,
}
