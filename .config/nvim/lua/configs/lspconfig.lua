-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"

local servers = {
  "cssls",
  "docker_compose_language_service",
  "dockerls",
  "html",
  "pyright",
  "ruby_lsp",
  "taplo",
  "terraformls",
  "typos_lsp",
  "volar",
}
local nvlsp = require "nvchad.configs.lspconfig"

-- Avoid conflict with tiny-inline-diagnostic.nvim
vim.diagnostic.config { virtual_text = false }

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  }
end

lspconfig.yamlls.setup {
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
  filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab", "yaml.ghaction" },
  settings = {
    yaml = {
      schemas = {
        ["https://json.schemastore.org/github-workflow.json"] = ".github/workflows/*.{yml,yaml}",
        ["https://json.schemastore.org/github-action.json"] = ".github/actions/*/*.{yml,yaml}",
        ["https://json.schemastore.org/prettierrc.json"] = ".prettierrc.{yml,yaml}",
        ["https://json.schemastore.org/stylelintrc.json"] = ".stylelintrc.{yml,yaml}",
        ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "(docker-)?compose.{yml,yaml}",
      },
    },
  },
}

lspconfig.ts_ls.setup {
  init_options = {
    plugins = {
      {
        name = "@vue/typescript-plugin",
        location = "/home/inuatsu/.local/share/pnpm/global/5/node_modules/@vue/typescript-plugin",
        languages = { "vue" },
      },
    },
  },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
    "vue",
  },
  capabilities = nvlsp.capabilities,
}
