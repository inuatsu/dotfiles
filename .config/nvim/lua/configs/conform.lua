local options = {
  formatters_by_ft = {
    css = { "prettier", "stylelint" },
    html = { "prettier" },
    javascript = { "prettierd", "eslint_d" },
    lua = { "stylua" },
    markdown = { "prettier", "markdownlint-cli2", "markdown-toc" },
    python = function(bufnr)
      if require("conform").get_formatter_info("ruff_format", bufnr).available then
        return { "ruff_fix", "ruff_format", "ruff_organize_imports" }
      else
        return { "isort", "black" }
      end
    end,
    ruby = { "rubocop" },
    typescript = { "prettierd", "eslint_d" },
    vue = { "prettierd", "eslint_d" },
  },
  formatters = {
    black = {
      prepend_args = { "--fast" },
    },
  },
  format_on_save = {
    -- These options will be passed to conform.format()
    lsp_format = "fallback",
    timeout_ms = 1000,
  },
}

return options
