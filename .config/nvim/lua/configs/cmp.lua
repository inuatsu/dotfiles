local options = {
  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
    { name = "nvim_lua" },
    { name = "path" },
    { name = "cmp-dbee" },
  },
}

return vim.tbl_deep_extend("force", require "nvchad.configs.cmp", options)
