require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- mapping augment commands
map({"n", "v"}, "<leader>ac", ":Augment chat<CR>")
map("n", "<leader>an", ":Augment chat-new<CR>")
map("n", "<leader>at", ":Augment chat-toggle<CR>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
