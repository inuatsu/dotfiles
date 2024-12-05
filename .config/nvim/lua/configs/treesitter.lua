local has_ts, ts_configs = pcall(require, "nvim-treesitter.configs")
if not has_ts then
  return
end

local langs = {
  "css",
  "csv",
  "diff",
  "dockerfile",
  "gitignore",
  "hcl",
  "html",
  "javascript",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "python",
  "ruby",
  "sql",
  "terraform",
  "toml",
  "typescript",
  "vim",
  "vimdoc",
  "vue",
  "yaml",
}

ts_configs.setup {
  ensure_installed = langs,
}
