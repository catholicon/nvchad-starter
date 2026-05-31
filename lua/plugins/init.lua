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
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        -- LSP servers
        "lua-language-server",
        "html-lsp", "css-lsp", "typescript-language-server",
        "clangd", "gopls", "rust-analyzer",
        "bash-language-server", "json-lsp", "yaml-language-server",
        "marksman",
        -- formatters
        "stylua", "prettier", "clang-format", "goimports", "shfmt",
        -- linters
        "luacheck",
        "eslint_d",
        "golangci-lint",
        "cpplint",
        "shellcheck",
        "yamllint",
        "markdownlint",
        -- DAP adapters
        "delve",              -- go
        "codelldb",           -- rust / c / c++
        "js-debug-adapter",   -- javascript / typescript
        "bash-debug-adapter", -- bash
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require "mason-registry"
      mr.refresh(function()
        for _, tool in ipairs(opts.ensure_installed or {}) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end)
    end,
  },

  -- Linting
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require "configs.lint"
    end,
  },

  -- DAP (debugger)
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        config = function()
          local dap, dapui = require "dap", require "dapui"
          dapui.setup()
          dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
          dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
          dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
        end,
      },
    },
    config = function()
      require "configs.dap"
    end,
  },

  -- Line number toggle (relative in normal, absolute in insert/unfocused)
  {
    "jeffkreeftmeijer/vim-numbertoggle",
    lazy = false,
  },

  -- Session save/restore per working directory
  {
    "rmagatti/auto-session",
    lazy = false,
    opts = {
      suppressed_dirs = { "~/", "~/Downloads", "/" },
    },
  },

  -- Code outline sidebar (functions, classes, methods)
  {
    "stevearc/aerial.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    keys = { "<leader>a" },
    config = function()
      require("aerial").setup {
        on_attach = function(bufnr)
          vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr, desc = "Aerial prev symbol" })
          vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr, desc = "Aerial next symbol" })
        end,
      }
    end,
  },

  -- Markdown presentations inside Neovim
  {
    "tjdevries/present.nvim",
    cmd = "PresentStart",
    config = function()
      require("present").setup {}
    end,
  },

  -- Rust LSP extras (hover actions, cargo commands, expand macros, runnables)
  -- Manages rust-analyzer directly — do NOT enable rust_analyzer via vim.lsp.enable
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    ft = "rust",
    config = function()
      vim.g.rustaceanvim = {
        server = {
          cmd = { vim.fn.stdpath "data" .. "/mason/bin/rust-analyzer" },
        },
      }
    end,
  },

  -- Neovim Lua API completions (vim.*, vim.api, etc.) for lua_ls
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "luvit-meta/library", words = { "vim%.uv" } },
      },
    },
  },

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
