local options = {
  formatters_by_ft = {
    -- lua
    lua = { "stylua" },
    -- web (html, css, js/ts, json, yaml, markdown)
    html = { "prettier" },
    css = { "prettier" },
    javascript = { "prettier" },
    typescript = { "prettier" },
    javascriptreact = { "prettier" },
    typescriptreact = { "prettier" },
    json = { "prettier" },
    yaml = { "prettier" },
    markdown = { "prettier" },
    -- python (ruff_format replaces black + isort)
    python = { "ruff_format" },
    -- go
    go = { "goimports", "gofmt" },
    -- rust (rustfmt ships with the toolchain, not via Mason)
    rust = { "rustfmt" },
    -- c / c++
    c = { "clang-format" },
    cpp = { "clang-format" },
    -- bash
    sh = { "shfmt" },
    bash = { "shfmt" },
  },

  -- format_on_save = {
  --   -- These options will be passed to conform.format()
  --   timeout_ms = 500,
  --   lsp_fallback = true,
  -- },
}

return options
