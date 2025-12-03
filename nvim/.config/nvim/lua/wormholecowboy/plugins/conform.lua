return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  keys = {
    {
      "<F6>",
      function()
        require("conform").format({
          lsp_format = "fallback",
          stop_after_first = true,
          async = false,
          timeout_ms = 1000,
        })
      end,
      mode = { "n", "v", "x" },
      desc = "format code",
    },
  },
  opts = {
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
  },
}
