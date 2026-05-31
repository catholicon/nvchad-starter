require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Scroll with cursor centered
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up (centered)" })

-- mapping augment commands
map({"n", "v"}, "<leader>ac", ":Augment chat<CR>")
map("n", "<leader>an", ":Augment chat-new<CR>")
map("n", "<leader>at", ":Augment chat-toggle<CR>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
