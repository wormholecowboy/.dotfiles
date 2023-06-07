local lsp = require('lsp-zero').preset({})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

-- (Optional) Configure lua language server for neovim
-- require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

lsp.setup()

-- cmp.setup {
--     mapping = cmp.mapping.preset.insert {
--          ["<CR>"] = cmp.mapping.confirm { select = false },
--     ["<Right>"] = cmp.mapping.confirm { select = true },
--     ["<Tab>"] = cmp.mapping(function(fallback)
--       if cmp.visible() then
--         cmp.select_next_item()
--       elseif luasnip.jumpable(1) then
--         luasnip.jump(1)
--       elseif luasnip.expand_or_jumpable() then
--         luasnip.expand_or_jump()
--       elseif luasnip.expandable() then
--         luasnip.expand()
--       elseif check_backspace() then
--         -- cmp.complete()
--         fallback()
--       else
--         fallback()
--       end
--     end, {
--       "i",
--       "s",
--     }),
--     ["<S-Tab>"] = cmp.mapping(function(fallback)
--       if cmp.visible() then
--         cmp.select_prev_item()
--       elseif luasnip.jumpable(-1) then
--         luasnip.jump(-1)
--       else
--         fallback()
--       end
--     end, {
--       "i",
--       "s",
--     }),
--   }
-- 
-- }
