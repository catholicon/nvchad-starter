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
vim.opt.list = true
vim.opt.listchars = {
  space = " ",
  tab = "  ",
  eol = "↵",
}

-- Thicker, more visible window separators
o.fillchars = "vert:┃,horiz:━,horizup:┻,horizdown:┳,vertleft:┫,vertright:┣,verthoriz:╋"

-- tab management
o.expandtab = true
o.tabstop = 2
o.shiftwidth = 2
o.softtabstop = 2
