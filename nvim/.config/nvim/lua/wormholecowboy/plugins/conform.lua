return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local conform = require("conform")

    conform.setup({
      formatters_by_ft = {
        python = { "isort", "black" },
        lua = { "stylua" },
        go = { "gofmt" },
        svelte = { "prettierd", "prettier" },
        javascript = { "prettierd", "prettier" },
        typescript = { "prettierd", "prettier" },
        javascriptreact = { "prettierd", "prettier" },
        typescriptreact = { "prettierd", "prettier" },
        json = { "prettierd", "prettier" },
        graphql = { "prettierd", "prettier" },
        java = { "google-java-format" },
        kotlin = { "ktlint" },
        ruby = { "standardrb" },
        markdown = { "prettierd", "prettier" },
        erb = { "htmlbeautifier" },
        html = { "htmlbeautifier" },
        bash = { "beautysh" },
        proto = { "buf" },
        rust = { "rustfmt" },
        yaml = { "yamlfix" },
        toml = { "taplo" },
        css = { "prettierd", "prettier" },
        scss = { "prettierd", "prettier" },
        sql = { "sql_formatter" },
      },
      -- format_on_save = {
      -- 	timeout_ms = 500,
      -- 	lsp_fallback = true,
      -- },
    })

    vim.keymap.set({ "n", "v", "x" }, "<F6>", function()
      conform.format({
        lsp_format = "fallback",
        stop_after_first = true,
        async = false,
        timeout_ms = 1000,
      })
    end, { desc = "Format code" })
  end,
}
