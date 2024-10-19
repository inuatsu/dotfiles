local utils = require "utils"

local function init_msg_progress(title, msg)
  return require("fidget.progress").handle.create {
    title = title,
    message = msg,
    lsp_client = { name = "conform.nvim" },
    percentage = nil,
  }
end

local options = {
  formatters_by_ft = {
    css = { "prettierd", "stylelint" },
    html = { "prettierd" },
    javascript = { "biome-check", "eslint_d", "prettierd" },
    javascriptreact = { "biome-check", "eslint_d", "prettierd" },
    lua = { "stylua" },
    markdown = { "markdownlint-cli2", "markdown-toc", "prettierd" },
    python = { "black", "isort", "ruff_fix", "ruff_format", "ruff_organize_imports" },
    ruby = { "rubocop" },
    scss = { "prettierd", "stylelint" },
    typescript = { "biome-check", "eslint_d", "prettierd" },
    typescriptreact = { "biome-check", "eslint_d", "prettierd" },
    vue = { "biome-check", "eslint_d", "prettierd" },
  },
  formatters = {
    ["biome-check"] = {
      command = function()
        local current_file_path = vim.fn.expand "%:p:h"
        local target_path = utils.recursive_find_project_root(current_file_path, "node_modules")
        if target_path and vim.fn.filereadable(string.format("%s/.bin/biome", target_path)) == 1 then
          return string.format("%s/.bin/biome", target_path)
        else
          return "biome"
        end
      end,
    },
    black = {
      command = function()
        local venv = vim.env.VIRTUAL_ENV
        if venv and vim.fn.filereadable(string.format("%s/bin/black", venv)) == 1 then
          return string.format("%s/bin/black", venv)
        else
          return "black"
        end
      end,
      prepend_args = { "--fast" },
    },
    eslint_d = {
      command = function()
        local current_file_path = vim.fn.expand "%:p:h"
        local target_path = utils.recursive_find_project_root(current_file_path, "node_modules")
        if target_path and vim.fn.filereadable(string.format("%s/.bin/eslint_d", target_path)) == 1 then
          return string.format("%s/.bin/eslint_d", target_path)
        else
          return "eslint_d"
        end
      end,
    },
    isort = {
      command = function()
        local venv = vim.env.VIRTUAL_ENV
        if venv and vim.fn.filereadable(string.format("%s/bin/isort", venv)) == 1 then
          return string.format("%s/bin/isort", venv)
        else
          return "isort"
        end
      end,
    },
    ["markdownlint-cli2"] = {
      command = function()
        local current_file_path = vim.fn.expand "%:p:h"
        local target_path = utils.recursive_find_project_root(current_file_path, "node_modules")
        if target_path and vim.fn.filereadable(string.format("%s/.bin/markdownlint-cli2", target_path)) == 1 then
          return string.format("%s/.bin/markdownlint-cli2", target_path)
        else
          return "markdownlint-cli2"
        end
      end,
    },
    ["markdown-toc"] = {
      command = function()
        local current_file_path = vim.fn.expand "%:p:h"
        local target_path = utils.recursive_find_project_root(current_file_path, "node_modules")
        if target_path and vim.fn.filereadable(string.format("%s/.bin/markdown-toc", target_path)) == 1 then
          return string.format("%s/.bin/markdown-toc", target_path)
        else
          return "markdown-toc"
        end
      end,
    },
    prettierd = {
      command = function()
        local current_file_path = vim.fn.expand "%:p:h"
        local target_path = utils.recursive_find_project_root(current_file_path, "node_modules")
        if target_path and vim.fn.filereadable(string.format("%s/.bin/prettierd", target_path)) == 1 then
          return string.format("%s/.bin/prettierd", target_path)
        else
          return "prettierd"
        end
      end,
    },
    ruff_fix = {
      command = function()
        local venv = vim.env.VIRTUAL_ENV
        if venv and vim.fn.filereadable(string.format("%s/bin/ruff", venv)) == 1 then
          return string.format("%s/bin/ruff", venv)
        else
          return "ruff"
        end
      end,
    },
    ruff_format = {
      command = function()
        local venv = vim.env.VIRTUAL_ENV
        if venv and vim.fn.filereadable(string.format("%s/bin/ruff", venv)) == 1 then
          return string.format("%s/bin/ruff", venv)
        else
          return "ruff"
        end
      end,
    },
    ruff_organize_imports = {
      command = function()
        local venv = vim.env.VIRTUAL_ENV
        if venv and vim.fn.filereadable(string.format("%s/bin/ruff", venv)) == 1 then
          return string.format("%s/bin/ruff", venv)
        else
          return "ruff"
        end
      end,
    },
    stylelint = {
      command = function()
        local current_file_path = vim.fn.expand "%:p:h"
        local target_path = utils.recursive_find_project_root(current_file_path, "node_modules")
        if target_path and vim.fn.filereadable(string.format("%s/.bin/stylelint", target_path)) == 1 then
          return string.format("%s/.bin/stylelint", target_path)
        else
          return "stylelint"
        end
      end,
    },
  },
  format_on_save = function(bufnr)
    local conform = require "conform"
    local formatters = conform.list_formatters()
    local fmt_names = {}

    if not vim.tbl_isempty(formatters) then
      fmt_names = vim.tbl_map(function(f)
        return f.name
      end, formatters)
    elseif select(2, conform.list_formatters_to_run(bufnr)) then
      fmt_names = { "lsp" }
    else
      return
    end

    local msg_info = table.concat(fmt_names, "/") .. ": formatting current buffer"
    local msg_handle = init_msg_progress(msg_info)
    return {
      -- These options will be passed to conform.format()
      lsp_format = "fallback",
      timeout_ms = 1000,
    }, function(_)
      msg_handle:finish()
    end
  end,
}

return options
