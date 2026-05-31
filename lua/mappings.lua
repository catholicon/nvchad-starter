require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP code action" })
map("n", "K", function() vim.lsp.buf.hover({ border = "rounded" }) end, { desc = "LSP hover" })
map("i", "jk", "<ESC>")

-- Scroll with cursor centered
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up (centered)" })

-- DAP (debugger)
map("n", "<F5>",  function() require("dap").continue() end,          { desc = "DAP continue" })
map("n", "<F10>", function() require("dap").step_over() end,         { desc = "DAP step over" })
map("n", "<F11>", function() require("dap").step_into() end,         { desc = "DAP step into" })
map("n", "<F12>", function() require("dap").step_out() end,          { desc = "DAP step out" })
map("n", "<leader>b",  function() require("dap").toggle_breakpoint() end, { desc = "DAP toggle breakpoint" })
map("n", "<leader>B",  function() require("dap").set_breakpoint(vim.fn.input "Breakpoint condition: ") end, { desc = "DAP conditional breakpoint" })
map("n", "<leader>du", function() require("dapui").toggle() end,     { desc = "DAP toggle UI" })
map("n", "<leader>dr", function() require("dap").repl.open() end,    { desc = "DAP open REPL" })

-- Present (markdown presentations)
map("n", "<leader>pp", "<cmd>PresentStart<CR>", { desc = "Start presentation" })

-- Free NvChad's <A-h/v/i> terminal toggles (using <leader>h/v instead)
vim.keymap.del({ "n", "t" }, "<A-v>")
vim.keymap.del({ "n", "t" }, "<A-h>")
vim.keymap.del({ "n", "t" }, "<A-i>")

-- Replace <C-h/j/k/l> window navigation (terminal conflicts) with <A-h/j/k/l>
vim.keymap.del("n", "<C-h>")
vim.keymap.del("n", "<C-j>")
vim.keymap.del("n", "<C-k>")
vim.keymap.del("n", "<C-l>")
map("n", "<A-h>", "<C-w>h", { desc = "switch window left" })
map("n", "<A-j>", "<C-w>j", { desc = "switch window down" })
map("n", "<A-k>", "<C-w>k", { desc = "switch window up" })
map("n", "<A-l>", "<C-w>l", { desc = "switch window right" })

-- Harpoon
local harpoon = require "harpoon"
map("n", "<leader>ha", function() harpoon:list():add() end,            { desc = "Harpoon add file" })
map("n", "<leader>hm", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon menu" })
map("n", "<leader>1",  function() harpoon:list():select(1) end,        { desc = "Harpoon file 1" })
map("n", "<leader>2",  function() harpoon:list():select(2) end,        { desc = "Harpoon file 2" })
map("n", "<leader>3",  function() harpoon:list():select(3) end,        { desc = "Harpoon file 3" })
map("n", "<leader>4",  function() harpoon:list():select(4) end,        { desc = "Harpoon file 4" })

-- mapping augment commands
map({"n", "v"}, "<leader>ac", ":Augment chat<CR>")
map("n", "<leader>an", ":Augment chat-new<CR>")
map("n", "<leader>at", ":Augment chat-toggle<CR>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
