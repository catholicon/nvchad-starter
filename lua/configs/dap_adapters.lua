local dap = require "dap"

-- When the debugger jumps to a source location, reuse a real code window
-- instead of a DAP UI sidebar or a tiny split.
dap.defaults.fallback.switchbuf = function(bufnr, line, col)
  local api = vim.api
  local wins = api.nvim_tabpage_list_wins(0)

  -- Prefer a window already showing the target buffer.
  for _, win in ipairs(wins) do
    if api.nvim_win_get_buf(win) == bufnr then
      api.nvim_set_current_win(win)
      if line then
        api.nvim_win_set_cursor(win, { line, (col or 0) })
      end
      return
    end
  end

  -- Otherwise pick the first usable code window (non-floating, not dapui).
  local function is_dapui(win)
    local ft = vim.bo[api.nvim_win_get_buf(win)].filetype
    return ft and ft:match "^dapui_" ~= nil
  end

  for _, win in ipairs(wins) do
    local cfg = api.nvim_win_get_config(win)
    if cfg.relative == "" and not is_dapui(win) then
      api.nvim_win_set_buf(win, bufnr)
      api.nvim_set_current_win(win)
      if line then
        api.nvim_win_set_cursor(win, { line, (col or 0) })
      end
      return
    end
  end

  -- Fallback to the current window.
  local curr = api.nvim_get_current_win()
  api.nvim_win_set_buf(curr, bufnr)
  if line then
    api.nvim_win_set_cursor(curr, { line, (col or 0) })
  end
end

-- ── Visible signs / highlights ───────────────────────────────────────────────
local hl = vim.api.nvim_set_hl
hl(0, "DapBreakpointColor", { fg = "#ff3333", ctermfg = 9 })
hl(0, "DapLogPointColor",   { fg = "#33ccff", ctermfg = 6 })
hl(0, "DapStoppedColor",    { fg = "#ffcc00", bg = "#5a5000", ctermfg = 11, ctermbg = 3 })
hl(0, "DapStoppedLine",     { bg = "#3a3500", ctermbg = 3 })

vim.fn.sign_define("DapBreakpoint",          { text = "●", texthl = "DapBreakpointColor", numhl = "DapBreakpointColor" })
vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpointColor", numhl = "DapBreakpointColor" })
vim.fn.sign_define("DapLogPoint",            { text = "◆", texthl = "DapLogPointColor",   numhl = "DapLogPointColor" })
vim.fn.sign_define("DapStopped",             { text = "▶", texthl = "DapStoppedColor",    linehl = "DapStoppedLine", numhl = "DapStoppedColor" })
vim.fn.sign_define("DapBreakpointRejected",  { text = "✖", texthl = "DapBreakpointColor", numhl = "DapBreakpointColor" })

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

-- ── C / C++ (GDB – native DAP, GDB 14+) ──────────────────────────────────────
-- GDB 14+ speaks DAP directly; no Mason adapter needed.
dap.adapters.gdb = {
  type = "executable",
  command = "gdb",
  args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
}
local gdb_cfg = {
  {
    name    = "Launch",
    type    = "gdb",
    request = "launch",
    program = function()
      return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd     = "${workspaceFolder}",
    stopAtBeginningOfMainSubprogram = true,
  },
  {
    name    = "Launch with args",
    type    = "gdb",
    request = "launch",
    program = function()
      return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    args    = function()
      return vim.split(vim.fn.input "Args: ", " ", { trimempty = true })
    end,
    cwd     = "${workspaceFolder}",
    stopAtBeginningOfMainSubprogram = true,
  },
  {
    name    = "Attach to process",
    type    = "gdb",
    request = "attach",
    program = function()
      return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    pid     = function()
      return require("dap.utils").pick_process()
    end,
    cwd     = "${workspaceFolder}",
  },
}
dap.configurations.c   = gdb_cfg
dap.configurations.cpp = gdb_cfg

-- ── Rust (codelldb – rustaceanvim manages rust-analyzer + dap) ────────────────
local codelldb_path = vim.fn.stdpath "data" .. "/mason/packages/codelldb/extension/adapter/codelldb"
dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = { command = codelldb_path, args = { "--port", "${port}" } },
}
dap.configurations.rust = {
  {
    type = "codelldb", name = "Launch file", request = "launch",
    program = function()
      return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = "${workspaceFolder}", stopOnEntry = false,
  },
}

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

-- ── Python (debugpy) ──────────────────────────────────────────────────────────
dap.adapters.python = {
  type = "executable",
  command = vim.fn.stdpath "data" .. "/mason/packages/debugpy/venv/bin/python",
  args = { "-m", "debugpy.adapter" },
}
dap.configurations.python = {
  {
    type = "python",
    request = "launch",
    name = "Launch file",
    program = "${file}",
    pythonPath = function()
      local venv = os.getenv "VIRTUAL_ENV"
      if venv then return venv .. "/bin/python" end
      return "python3"
    end,
  },
  {
    type = "python",
    request = "launch",
    name = "Launch with args",
    program = "${file}",
    args = function() return vim.split(vim.fn.input "Args: ", " ") end,
    pythonPath = function()
      local venv = os.getenv "VIRTUAL_ENV"
      if venv then return venv .. "/bin/python" end
      return "python3"
    end,
  },
}

-- ── Bash / sh (bash-debug-adapter) ────────────────────────────────────────────
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
