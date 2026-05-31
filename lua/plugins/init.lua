return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- Setup augment code
  {
    "augmentcode/augment.vim",
    lazy = false,
  },
  --
  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        -- nvchad defaults
        "lua", "luadoc", "printf", "vim", "vimdoc",
        -- web
        "html", "css", "javascript", "typescript", "tsx",
        -- systems
        "c", "cpp", "go", "rust",
        -- scripting / config
        "bash", "json", "yaml",
        -- docs
        "markdown", "markdown_inline",
      },
    },
    init = function()
      -- Highlighting is handled by NvChad's FileType autocmd (pcall vim.treesitter.start)
      -- This adds treesitter-based indentation on top
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
}
