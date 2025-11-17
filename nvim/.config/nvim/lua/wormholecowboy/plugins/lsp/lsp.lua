return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    -- this next plugin is for renaming files and fixing imports
    { "antosha417/nvim-lsp-file-operations", config = true },
  },
  config = function()
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    -- Add Mason bin directory to PATH for LSP servers
    local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
    vim.env.PATH = mason_bin .. ":" .. vim.env.PATH

    -- Configure diagnostics globally
    vim.diagnostic.config({
      virtual_text = false,
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = "⛔",
          [vim.diagnostic.severity.WARN] = "⚠️",
          [vim.diagnostic.severity.HINT] = "🔬",
          [vim.diagnostic.severity.INFO] = "ℹ️",
        },
      },
      underline = true,
      update_in_insert = false,
      severity_sort = false,
    })

    -- Ensure diagnostic signs are defined (fallback for older Neovim versions)
    vim.fn.sign_define("DiagnosticSignError", { text = " ", texthl = "DiagnosticSignError" })
    vim.fn.sign_define("DiagnosticSignWarn", { text = " ", texthl = "DiagnosticSignWarn" })
    vim.fn.sign_define("DiagnosticSignHint", { text = "󰠠 ", texthl = "DiagnosticSignHint" })
    vim.fn.sign_define("DiagnosticSignInfo", { text = " ", texthl = "DiagnosticSignInfo" })

    -- Get capabilities from cmp-nvim-lsp
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- Configure global LSP settings (applies to all servers)
    vim.lsp.config("*", {
      capabilities = capabilities,
      root_markers = { ".git" },
    })

    -- Set up LspAttach autocmd for keymaps (replaces on_attach)
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("lsp_attach_keymaps", { clear = true }),
      callback = function(args)
        local opts = { noremap = true, silent = true, buffer = args.buf }

        opts.desc = "Show LSP references"
        vim.keymap.set("n", "gr", "<cmd>FzfLua lsp_references<CR>", opts)

        opts.desc = "Go to declaration"
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

        opts.desc = "Show LSP definitions"
        vim.keymap.set("n", "gd", "<cmd>FzfLua lsp_definitions<CR>", opts)

        opts.desc = "Show LSP implementations"
        vim.keymap.set("n", "gi", "<cmd>FzfLua lsp_implementations<CR>", opts)

        opts.desc = "Show LSP type definitions"
        vim.keymap.set("n", "gt", "<cmd>FzfLua lsp_typedefs<CR>", opts)

        opts.desc = "Smart rename"
        vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, opts)

        opts.desc = "Show line diagnostics"
        vim.keymap.set("n", "gl", vim.diagnostic.open_float, opts)

        opts.desc = "Go to previous diagnostic"
        vim.keymap.set("n", "[d", function()
          vim.diagnostic.jump({ count = -1 })
          vim.diagnostic.open_float()
        end, opts)

        opts.desc = "Go to next diagnostic"
        vim.keymap.set("n", "]d", function()
          vim.diagnostic.jump({ count = 1 })
          vim.diagnostic.open_float()
        end, opts)

        opts.desc = "Show documentation for what is under cursor"
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      end,
    })

    -- Configure individual LSP servers using vim.lsp.config
    vim.lsp.config("html", {})

    vim.lsp.config("gopls", {})

    vim.lsp.config("bashls", {})

    vim.lsp.config("ts_ls", {
      root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
    })

    vim.lsp.config("cssls", {})

    vim.lsp.config("tailwindcss", {
      filetypes = {
        "html",
        "css",
        "scss",
        "sass",
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "vue",
        "svelte",
        "astro",
      },
      root_markers = {
        "tailwind.config.js",
        "tailwind.config.cjs",
        "tailwind.config.mjs",
        "tailwind.config.ts",
        "postcss.config.js",
        "postcss.config.cjs",
        "postcss.config.mjs",
        "postcss.config.ts",
        ".git",
      },
    })

    vim.lsp.config("terraformls", {
      filetypes = { "terraform", "terraform-vars" },
    })

    vim.lsp.config("tflint", {
      filetypes = { "terraform", "terraform-vars" },
    })

    vim.lsp.config("prismals", {})

    vim.lsp.config("graphql", {
      filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
    })

    vim.lsp.config("emmet_ls", {
      filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
    })

    vim.lsp.config("pyright", {
      filetypes = { "python" },
    })

    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          -- make the language server recognize "vim" global
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            -- make language server aware of runtime files
            library = {
              [vim.fn.expand("$VIMRUNTIME/lua")] = true,
              [vim.fn.stdpath("config") .. "/lua"] = true,
            },
          },
        },
      },
    })

    -- Enable all configured LSP servers
    vim.lsp.enable({
      "html",
      "gopls",
      "bashls",
      "ts_ls",
      "cssls",
      "tailwindcss",
      "terraformls",
      "tflint",
      "prismals",
      "graphql",
      "emmet_ls",
      "pyright",
      "lua_ls",
    })
  end,
}
