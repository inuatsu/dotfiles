vim.g.base46_cache = vim.fn.stdpath "data" .. "/nvchad/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "nvchad.autocmds"

vim.schedule(function()
  require "mappings"
end)

-- setup nvim-tree
require("nvim-tree").setup {
  filters = {
    git_ignored = false,
    custom = {
      "^\\.git$",
      "^node_modules",
      "^.venv",
      "^.mypy_cache",
      "^.pytest_cache",
      "^.vscode",
      "^__pycache__",
      "^htmlcov",
      "^.ruby-lsp",
      "^.coverage",
    },
  },
}

-- automatically open file tree
local function open_nvim_tree()
  -- open the tree
  require("nvim-tree.api").tree.open()
end

vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })

-- LSP server attachment command
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ctx)
    local set = vim.keymap.set
    set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", { buffer = true })
    set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { buffer = true })
    set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", { buffer = true })
    set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", { buffer = true })
    set("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", { buffer = true })
    set("n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", { buffer = true })
    set("n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", { buffer = true })
    set("n", "<space>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", { buffer = true })
    set("n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", { buffer = true })
    set("n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", { buffer = true })
    set("n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", { buffer = true })
    set("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", { buffer = true })
    set("n", "<space>e", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", { buffer = true })
    set("n", "[d", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", { buffer = true })
    set("n", "]d", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", { buffer = true })
    set("n", "<space>q", "<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>", { buffer = true })
    set("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", { buffer = true })
  end,
})

-- Helper function to check if pyright is attached to the current buffer
local function is_pyright_attached()
  local clients = vim.lsp.get_active_clients()
  for _, client in ipairs(clients) do
    if client.name == "pyright" and vim.lsp.buf_is_attached(0, client.id) then
      return true
    end
  end
  return false
end

-- Function that waits for pyright to attach and then calls the provided callback
local function wait_for_lsp(callback)
  local timer = vim.loop.new_timer()
  local interval = 100 -- Check every 100ms
  local max_attempts = 50 -- Maximum attempts before timeout (e.g., 5 seconds)

  local attempts = 0

  -- Start the polling loop
  timer:start(
    0,
    interval,
    vim.schedule_wrap(function()
      attempts = attempts + 1

      if is_pyright_attached() then
        -- If pyright is attached, stop the timer and run the callback
        timer:stop()
        timer:close()
        callback()
      elseif attempts >= max_attempts then
        -- Stop checking after max attempts (timeout)
        timer:stop()
        timer:close()
        vim.notify("pyright not activated in time", vim.log.levels.WARN)
      end
    end)
  )
end

-- Automatically activate workspace venv
local venv_selector = require "venv-selector"

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.py",
  callback = function()
    wait_for_lsp(function()
      local workspace_paths = venv_selector.workspace_paths()

      if #workspace_paths == 0 then
        -- Skip venv activation if no workspace paths are found
        vim.notify("No workspace venv found. Skipping activation.", vim.log.levels.INFO)
        return
      end

      venv_selector.activate_from_path(string.format("%s/.venv/bin/python", workspace_paths[#workspace_paths]))
    end)
  end,
})
