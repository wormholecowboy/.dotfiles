return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "L3MON4D3/LuaSnip",
    "onsails/lspkind.nvim",
    { "roobert/tailwindcss-colorizer-cmp.nvim", config = true },
  },
  config = function()
    local cmp = require("cmp")
    local lspkind = require("lspkind")
    lspkind.init({})
    local tailwind_formatter = require("tailwindcss-colorizer-cmp").formatter

    -- get luasnip loading logs
    -- require("luasnip").log.set_loglevel("info")
    -- :lua require("luasnip").log.open()

    require("cmp").config.formatting = {
      format = require("tailwindcss-colorizer-cmp").formatter,
    }

    require("cmp-npm").setup({})

    cmp.setup({
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      },
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer", keyword_length = 3 },
        { name = "npm", keyword_length = 4 },
        { name = "path" },
        { name = "codeium" },
      }),
      completion = {
        completeopt = "menu,menuone,preview,noinsert",
      },
      window = {
        completion = {
          winhighlight = "Normal:Pmenu,CursorLine:PmenuSel,FloatBorder:FloatBorder,Search:None",
          col_offset = -3,
          side_padding = 1,
          scrollbar = false,
          scrolloff = 8,
        },
        documentation = {
          winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,Search:None",
        },
      },
      mapping = {
        ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-l>"] = cmp.mapping.confirm({ select = true }),
        ["<C-y>"] = cmp.mapping(
          cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = true,
          }),
          { "i", "c" }
        ),
      },
      formatting = {
        format = lspkind.cmp_format({
          maxwidth = 50,
          ellipsis_char = "...",
          menu = {
            nvim_lsp = "lsp",
            nvim_lua = "lua",
            path = "path",
            buffer = "buf",
            luasnip = "snip",
            treesitter = "",
            zsh = "",
            codieum = "󰚩",
          },
          before = tailwind_formatter,
        }),
      },
    })
  end,
}
