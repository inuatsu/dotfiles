local utils = require "utils"

local lint = require "lint"

vim.filetype.add {
  pattern = {
    [".*/.github/actions/*/.*%.yml"] = "yaml.ghaction",
    [".*/.github/actions/*/.*%.yaml"] = "yaml.ghaction",
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

lint.linters.mypy.args = {
  "--show-column-numbers",
  "--show-error-end",
  "--hide-error-context",
  "--no-color-output",
  "--no-error-summary",
  "--no-pretty",
}

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

local lint_fidget_notify = function()
  local linters = require("lint").get_running()
  if #linters > 0 then
    require("fidget.progress").handle.create {
      title = table.concat(linters, "/") .. " " .. "linting current buffer",
      message = nil,
      lsp_client = { name = "nvim-lint" },
      percentage = nil,
    }
  end
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
  callback = function()
    lint.try_lint(nil, { ignore_errors = true })
    lint.try_lint("typos", { ignore_errors = true })
    lint_fidget_notify()
  end,
})

local function get_linter_filetypes(name)
  local filetypes = {}
  for filetype, linters in pairs(lint.linters_by_ft) do
    if type(linters) == "function" then
      linters = linters(0)
    end

    for _, linter in ipairs(linters) do
      if type(linter) == "string" then
        if linter == name then
          table.insert(filetypes, filetype)
          break
        end
      else
        if vim.tbl_contains(linter, name) then
          table.insert(filetypes, filetype)
          break
        end
      end
    end
  end
  if #filetypes == 0 then
    table.insert(filetypes, "all")
  end
  return filetypes
end

local function get_all_linters()
  local all_linters = {}
  for _, linters in pairs(lint.linters_by_ft) do
    if type(linters) == "function" then
      linters = linters(0)
    end

    for _, linter in ipairs(linters) do
      if not vim.tbl_contains(all_linters, linter) then
        table.insert(all_linters, linter)
      end
    end
  end
  return all_linters
end

local function show_window()
  local lines = {}
  local highlights = {}

  local function append_linter_info(linter)
    local cmd = lint.linters[linter].cmd
    if type(cmd) == "function" then
      cmd = cmd()
    end

    if vim.fn.exepath(cmd) == "" then
      local line = string.format("%s unavailable: %s", linter, "Command not found")
      table.insert(lines, line)
      table.insert(highlights, { "DiagnosticWarn", #lines, linter:len(), linter:len() + 12 })
    else
      local filetypes = get_linter_filetypes(linter)
      local filetypes_list = table.concat(filetypes, ", ")
      local path = vim.fn.exepath(cmd)
      local line = string.format("%s ready (%s) %s", linter, filetypes_list, path)
      table.insert(lines, line)
      table.insert(highlights, {
        "DiagnosticOk",
        #lines,
        linter:len(),
        linter:len() + 6,
      })
      table.insert(highlights, {
        "DiagnosticInfo",
        #lines,
        linter:len() + 7 + filetypes_list:len() + 3,
        line:len(),
      })
    end
  end

  local seen = {}
  local function append_linters(linters)
    for _, name in ipairs(linters) do
      seen[name] = true
      append_linter_info(name)
    end
  end

  local filetype = vim.bo.filetype
  if filetype == "yaml.ghaction" then
    filetype = "ghaction"
  end

  table.insert(lines, string.format("Detected filetype: %s", filetype))
  table.insert(highlights, { "Title", #lines, 0, 18 })

  table.insert(lines, "")
  table.insert(lines, "Linters for this buffer:")
  table.insert(highlights, { "Title", #lines, 0, -1 })

  local buf_linters = lint.linters_by_ft[filetype] or {}
  append_linters(buf_linters)
  append_linter_info "typos" -- typos is used for any filetype

  table.insert(lines, "")
  table.insert(lines, "Other linters:")
  table.insert(highlights, { "Title", #lines, 0, -1 })

  for _, linter in ipairs(get_all_linters()) do
    if not seen[linter] then
      append_linter_info(linter)
    end
  end

  local bufnr = vim.api.nvim_create_buf(false, true)
  local winid = vim.api.nvim_open_win(bufnr, true, {
    relative = "editor",
    border = "rounded",
    width = vim.o.columns - 6,
    height = vim.o.lines - 6,
    col = 2,
    row = 2,
    style = "minimal",
  })
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, lines)
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].modified = false
  vim.bo[bufnr].bufhidden = "wipe"
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = bufnr, nowait = true })
  vim.keymap.set("n", "<C-c>", "<cmd>close<cr>", { buffer = bufnr })
  vim.api.nvim_create_autocmd("BufLeave", {
    desc = "Close info window when leaving buffer",
    buffer = bufnr,
    once = true,
    nested = true,
    callback = function()
      if vim.api.nvim_win_is_valid(winid) then
        vim.api.nvim_win_close(winid, true)
      end
    end,
  })
  local ns = vim.api.nvim_create_namespace "conform"
  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(bufnr, ns, hl[1], hl[2] - 1, hl[3], hl[4])
  end
end

vim.api.nvim_create_user_command("LinterInfo", function()
  show_window()
end, { desc = "Show information about linters" })
