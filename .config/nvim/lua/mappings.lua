require "nvchad.mappings"

local map = vim.keymap.set
local kopts = {noremap = true, silent = true}

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- hlslens
map("n", "n",
    [[<Cmd>execute("normal! " . v:count1 . "n")<CR><Cmd>lua require("hlslens").start()<CR>]],
    kopts)
map("n", "N",
    [[<Cmd>execute("normal! " . v:count1 . "N")<CR><Cmd>lua require("hlslens").start()<CR>]],
    kopts)
map("n", "*", [[*<Cmd>lua require("hlslens").start()<CR>]], kopts)
map("n", "#", [[#<Cmd>lua require("hlslens").start()<CR>]], kopts)
map("n", "g*", [[g*<Cmd>lua require("hlslens").start()<CR>]], kopts)
map("n", "g#", [[g#<Cmd>lua require("hlslens").start()<CR>]], kopts)
map("n", "<Leader>l", "<Cmd>noh<CR>", kopts)