return {
  "rachartier/tiny-cmdline.nvim",
  init = function()
    -- Required before plugin init, else cmdline stays bottom-aligned
    vim.o.cmdheight = 0
  end,
  config = function()
    -- Plugin hooks into ui2 but does not enable it; without this the
    -- floating cmdline window never exists and the plugin is inert
    require("vim._core.ui2").enable({})
    require("tiny-cmdline").setup({})
  end,
}
