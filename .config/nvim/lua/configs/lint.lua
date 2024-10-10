local utils = require "utils"

local lint = require "lint"

vim.filetype.add {
  pattern = {
    [".*/.github/actions/**/.*%.yml"] = "yaml.ghaction",
    [".*/.github/actions/**/.*%.yaml"] = "yaml.ghaction",
    [".*/.github/workflows/.*%.yml"] = "yaml.ghaction",
    [".*/.github/workflows/.*%.yaml"] = "yaml.ghaction",
  },
}

lint.linters_by_ft = {
  css = { "stylelint" },
  dockerfile = { "hadolint" },
  ghaction = { "actionlint" },
  javascript = { "biomejs", "eslint" },
  javascriptreact = { "biomejs", "eslint" },
  markdown = { "markdownlint-cli2" },
  python = { "flake8", "mypy", "ruff" },
  ruby = { "rubocop" },
  scss = { "stylelint" },
  typescript = { "biomejs", "eslint" },
  typescriptreact = { "biomejs", "eslint" },
  vue = { "biomejs", "eslint" },
}

lint.linters.biomejs.cmd = function()
  local current_file_path = vim.fn.expand "%:p:h"
  local target_path = utils.recursive_find_project_root(current_file_path, "node_modules")
  if target_path and vim.fn.filereadable(string.format("%s/.bin/biome", target_path)) == 1 then
    return string.format("%s/.bin/biomejs", target_path)
  else
    return "biome"
  end
end

lint.linters.eslint.cmd = function()
  local current_file_path = vim.fn.expand "%:p:h"
  local target_path = utils.recursive_find_project_root(current_file_path, "node_modules")
  if target_path and vim.fn.filereadable(string.format("%s/.bin/eslint", target_path)) == 1 then
    return string.format("%s/.bin/eslint", target_path)
  else
    return "eslint"
  end
end

lint.linters.flake8.args = {
  "--max-line-length=120",
  "--format=%(path)s:%(row)d:%(col)d:%(code)s:%(text)s",
  "--no-show-source",
  "--stdin-display-name",
  function()
    return vim.api.nvim_buf_get_name(0)
  end,
  "-",
}

lint.linters.flake8.cmd = function()
  local venv = vim.env.VIRTUAL_ENV
  if venv and vim.fn.filereadable(string.format("%s/bin/flake8", venv)) == 1 then
    return string.format("%s/bin/flake8", venv)
  else
    return "flake8"
  end
end

lint.linters["markdownlint-cli2"].cmd = function()
  local current_file_path = vim.fn.expand "%:p:h"
  local target_path = utils.recursive_find_project_root(current_file_path, "node_modules")
  if target_path and vim.fn.filereadable(string.format("%s/.bin/markdownlint-cli2", target_path)) == 1 then
    return string.format("%s/.bin/markdownlint-cli2", target_path)
  else
    return "markdownlint-cli2"
  end
end

lint.linters.mypy.cmd = function()
  local venv = vim.env.VIRTUAL_ENV
  if venv and vim.fn.filereadable(string.format("%s/bin/mypy", venv)) == 1 then
    return string.format("%s/bin/mypy", venv)
  else
    return "mypy"
  end
end

lint.linters.ruff.cmd = function()
  local venv = vim.env.VIRTUAL_ENV
  if venv and vim.fn.filereadable(string.format("%s/bin/ruff", venv)) == 1 then
    return string.format("%s/bin/ruff", venv)
  else
    return "ruff"
  end
end

lint.linters.stylelint.cmd = function()
  local current_file_path = vim.fn.expand "%:p:h"
  local target_path = utils.recursive_find_project_root(current_file_path, "node_modules")
  if target_path and vim.fn.filereadable(string.format("%s/.bin/stylelint", target_path)) == 1 then
    return string.format("%s/.bin/stylelint", target_path)
  else
    return "stylelint"
  end
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
  callback = function()
    lint.try_lint(nil, { ignore_errors = true })
    lint.try_lint("typos", { ignore_errors = true })
  end,
})
