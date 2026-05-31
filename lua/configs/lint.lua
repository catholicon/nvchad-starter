local lint = require "lint"

lint.linters_by_ft = {
  -- lua
  lua = { "luacheck" },
  -- web
  javascript = { "eslint_d" },
  typescript = { "eslint_d" },
  javascriptreact = { "eslint_d" },
  typescriptreact = { "eslint_d" },
  -- python (ruff replaces flake8 + pylint + isort)
  python = { "ruff" },
  -- go
  go = { "golangci-lint" },
  -- c / c++ diagnostics handled by clangd LSP
  -- bash
  sh = { "shellcheck" },
  bash = { "shellcheck" },
  -- config / docs
  yaml = { "yamllint" },
  markdown = { "markdownlint" },
}

-- Run linting on open + save
vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
  callback = function()
    lint.try_lint()
  end,
})
