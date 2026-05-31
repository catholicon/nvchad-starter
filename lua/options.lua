require "nvchad.options"

-- add yours here!

local o = vim.o
o.relativenumber = true
-- o.cursorlineopt ='both' -- to enable cursorline!

-- Keep cursor vertically centered while scrolling
o.scrolloff = 10

-- Show column ruler at 100 chars
o.colorcolumn = "100"

-- Visualize whitespace characters
o.list = true
o.listchars = "space:⋅,eol:↴"
