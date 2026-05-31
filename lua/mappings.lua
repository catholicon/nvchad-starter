require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
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

-- Aerial (code outline)
map("n", "<leader>a", "<cmd>AerialToggle!<CR>", { desc = "Aerial toggle outline" })

-- Present (markdown presentations)
map("n", "<leader>pp", "<cmd>PresentStart<CR>", { desc = "Start presentation" })

-- mapping augment commands
map({"n", "v"}, "<leader>ac", ":Augment chat<CR>")
map("n", "<leader>an", ":Augment chat-new<CR>")
map("n", "<leader>at", ":Augment chat-toggle<CR>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
