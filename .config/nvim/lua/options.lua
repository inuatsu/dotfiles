require "nvchad.options"


local o = vim.o
o.cursorlineopt ="both"

vim.api.nvim_set_option_value("clipboard", "unnamedplus", {})