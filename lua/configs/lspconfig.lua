require("nvchad.configs.lspconfig").defaults()

-- read :h vim.lsp.config for changing options of lsp servers

vim.lsp.enable {
  -- lua
  "lua_ls",
  -- web
  "html", "cssls", "ts_ls",
  -- systems (rust_analyzer omitted — managed by rustaceanvim)
  "gopls",
  -- python
  "pyright",
  -- scripting / config
  "bashls", "jsonls", "yamlls",
  -- docs
  "marksman",
}

-- clangd needs explicit utf-16 offset encoding to avoid conflicts
vim.lsp.config("clangd", {
  cmd = { "clangd", "--offset-encoding=utf-16" },
})
vim.lsp.enable "clangd"
