local dap = require "dap"

-- ── Go (delve) ────────────────────────────────────────────────────────────────
dap.adapters.delve = {
  type = "server",
  port = "${port}",
  executable = {
    command = vim.fn.stdpath "data" .. "/mason/bin/dlv",
    args = { "dap", "-l", "127.0.0.1:${port}" },
  },
}
dap.configurations.go = {
  { type = "delve", name = "Debug", request = "launch", program = "${file}" },
  { type = "delve", name = "Debug test", request = "launch", mode = "test", program = "${file}" },
  { type = "delve", name = "Debug package", request = "launch", program = "${fileDirname}" },
}

-- ── Rust / C / C++ (codelldb) ─────────────────────────────────────────────────
local codelldb_path = vim.fn.stdpath "data" .. "/mason/packages/codelldb/extension/adapter/codelldb"
dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = { command = codelldb_path, args = { "--port", "${port}" } },
}
local codelldb_cfg = {
  {
    type = "codelldb",
    name = "Launch file",
    request = "launch",
    program = function() return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file") end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
  },
}
dap.configurations.rust = codelldb_cfg
dap.configurations.c    = codelldb_cfg
dap.configurations.cpp  = codelldb_cfg

-- ── JavaScript / TypeScript (js-debug-adapter) ────────────────────────────────
local js_debug = vim.fn.stdpath "data" .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"
for _, type in ipairs { "node", "chrome", "pwa-node", "pwa-chrome" } do
  dap.adapters[type] = {
    type = "server",
    host = "localhost",
    port = "${port}",
    executable = { command = "node", args = { js_debug, "${port}" } },
  }
end
local js_cfg = {
  { type = "pwa-node", request = "launch", name = "Launch file", program = "${file}", cwd = "${workspaceFolder}" },
  { type = "pwa-node", request = "attach", name = "Attach", processId = require("dap.utils").pick_process, cwd = "${workspaceFolder}" },
}
dap.configurations.javascript = js_cfg
dap.configurations.typescript = js_cfg
dap.configurations.javascriptreact = js_cfg
dap.configurations.typescriptreact = js_cfg

-- ── Bash (bash-debug-adapter) ─────────────────────────────────────────────────
local bash_debug = vim.fn.stdpath "data" .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir"
dap.adapters.sh = {
  type = "executable",
  command = vim.fn.stdpath "data" .. "/mason/bin/bash-debug-adapter",
}
dap.configurations.sh = {
  {
    type = "sh",
    request = "launch",
    name = "Launch bash script",
    program = "${file}",
    pathBashdb = bash_debug .. "/bashdb",
    pathBashdbLib = bash_debug,
    pathBash = "bash",
    pathCat = "cat",
    pathMkfifo = "mkfifo",
    pathPkill = "pkill",
    env = {},
    args = {},
    terminalKind = "integrated",
  },
}
