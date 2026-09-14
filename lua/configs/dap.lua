-- ── Custom command-line launcher ───────────────────────────────────────────────
-- M.run_prompt()  – ask for a command line (pre-filled with last used), then run
-- M.run_last()    – re-run the last command without prompting
-- M.run_autotest()      – prompt for autotest category and run
-- M.run_last_autotest() – re-run the last autotest with the same category
-- M.run_javascript()    – prompt for a JavaScript file path and run under nlserver
-- M.run_last_javascript() – re-run the last JavaScript file
local M = {}
local _last_cmd = nil               -- session-scoped last raw command
local _last_autotest_cat = nil      -- last autotest category
local _last_autotest_cfg = nil      -- fully-resolved last autotest dap config
local _last_javascript_path = nil   -- last JavaScript file path
local _last_javascript_cfg = nil    -- fully-resolved last javascript dap config

local function has_active_dap_session()
  local ok, dap = pcall(require, "dap")
  if not ok then return false end
  local sessions = dap.sessions()
  if sessions then
    for _ in pairs(sessions) do
      return true
    end
  end
  return false
end

local function guard_no_active_session()
  if has_active_dap_session() then
    vim.notify(
      "[DAP] A session is already active. Use <leader>dx to terminate, <leader>dR to restart, or <leader>dA/<leader>dJ to re-run the last autotest/javascript after closing the current one.",
      vim.log.levels.WARN
    )
    return true
  end
  return false
end

local function maybe_engine_env()
  local engine = os.getenv "NL_JS_ENGINE" or os.getenv "ENGINE"
  if engine and engine ~= "" then
    local env = vim.fn.environ()
    env.NL_JS_ENGINE = engine
    return env
  end
  return nil
end

-- Simple shell-style splitter: honours single and double quotes
local function shell_split(s)
  local parts, i = {}, 1
  while i <= #s do
    local c = s:sub(i, i)
    if c == " " or c == "\t" then
      i = i + 1
    elseif c == '"' or c == "'" then
      local q, j = c, i + 1
      while j <= #s and s:sub(j, j) ~= q do
        j = j + 1
      end
      parts[#parts + 1] = s:sub(i + 1, j - 1)
      i = j + 1
    else
      local j = s:find("[ \t]", i) or (#s + 1)
      parts[#parts + 1] = s:sub(i, j - 1)
      i = j
    end
  end
  return parts
end

-- Build a dap.run() config from a raw command string, auto-detecting adapter
local function make_dap_config(cmdline)
  local parts = shell_split(cmdline)
  if #parts == 0 then return nil end
  local program = parts[1]
  local args = { table.unpack(parts, 2) }
  local ext = (program:match "%.([^.]+)$" or ""):lower()

  if ext == "py" then
    return {
      type = "python", request = "launch", name = "cmd: " .. cmdline,
      program = program, args = args,
      pythonPath = function()
        local venv = os.getenv "VIRTUAL_ENV"
        return (venv and venv ~= "") and (venv .. "/bin/python") or "python3"
      end,
    }
  elseif ext == "js" or ext == "mjs" or ext == "cjs" or ext == "ts" then
    return {
      type = "pwa-node", request = "launch", name = "cmd: " .. cmdline,
      program = program, args = args, cwd = vim.fn.getcwd(),
    }
  elseif ext == "go" then
    return {
      type = "delve", request = "launch", name = "cmd: " .. cmdline,
      mode = "exec", program = program, args = args,
    }
  elseif ext == "sh" or ext == "bash" then
    local bashdb = vim.fn.stdpath "data" .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir"
    return {
      type = "sh", request = "launch", name = "cmd: " .. cmdline,
      program = program, args = args,
      pathBashdb = bashdb .. "/bashdb", pathBashdbLib = bashdb,
      pathBash = "bash", pathCat = "cat", pathMkfifo = "mkfifo", pathPkill = "pkill",
      env = {}, terminalKind = "integrated",
    }
  else
    -- native binary – use gdb
    return {
      type = "gdb", request = "launch", name = "cmd: " .. cmdline,
      program = program, args = args, cwd = vim.fn.getcwd(),
      stopAtBeginningOfMainSubprogram = false,
    }
  end
end

local function _run(cmdline)
  if guard_no_active_session() then return end
  local cfg = make_dap_config(cmdline)
  if not cfg then return end
  _last_cmd = cmdline
  require("dap").run(cfg)
end

-- Prompt for a command line; last used is pre-filled so you can edit or accept
function M.run_prompt()
  vim.ui.input({ prompt = "Debug command: ", default = _last_cmd or "" }, function(input)
    if input and input ~= "" then _run(input) end
  end)
end

-- Re-run the last command without prompting
function M.run_last()
  if not _last_cmd then
    vim.notify("[DAP] No previous command – use <leader>dc first", vim.log.levels.WARN)
    return
  end
  _run(_last_cmd)
end

-- Resolve the nlserver path from NL_PATH, or fall back to PATH lookup
local function resolve_nlserver()
  local nl = os.getenv "NL_PATH"
  if nl and nl ~= "" then
    local candidate = nl .. "/bin/nlserver"
    if vim.fn.filereadable(candidate) == 1 or vim.fn.executable(candidate) == 1 then
      return candidate
    end
  end
  local from_path = vim.fn.exepath "nlserver"
  if from_path and from_path ~= "" then return from_path end
  return "nlserver" -- let the adapter report the error if missing
end

-- Build and run the autotest configuration
local function _run_autotest(category)
  if guard_no_active_session() then return end
  local nl = os.getenv "NL_PATH"
  if not nl or nl == "" then
    vim.notify("[DAP] NL_PATH is not set", vim.log.levels.ERROR)
    return
  end
  local instance = os.getenv "INSTANCE" or "autotest"
  local args = { "javascript", "-instance:" .. instance }
  local env = maybe_engine_env()
  local cat = (category or ""):match("^%s*(.-)%s*$")
  if cat ~= "" then
    -- Only add -arg when a non-empty category was provided; an empty/blank input means "run all tests".
    -- The examples put -arg: BEFORE -file main.js, so do the same here.
    table.insert(args, "-arg:" .. cat)
  end
  table.insert(args, "-file")
  table.insert(args, "main.js")
  local cfg = {
    name    = "Autotest" .. (category and category ~= "" and (" [" .. category .. "]") or ""),
    type    = "gdb",
    request = "launch",
    program = resolve_nlserver(),
    args    = args,
    cwd     = nl .. "/test/autotest",
    env     = env,
  }
  _last_autotest_cat = category
  _last_autotest_cfg = cfg
  require("dap").run(cfg)
end

function M.run_autotest()
  local cat = vim.fn.input("Test category (empty = all): ", _last_autotest_cat or "")
  _run_autotest(cat)
end

function M.run_last_autotest()
  if not _last_autotest_cfg then
    vim.notify("[DAP] No previous autotest – use <leader>da first", vim.log.levels.WARN)
    return
  end
  require("dap").run(_last_autotest_cfg)
end

-- Build and run a JavaScript file under nlserver javascript (no cwd change)
local function _run_javascript(path)
  if guard_no_active_session() then return end
  local nl = os.getenv "NL_PATH"
  if not nl or nl == "" then
    vim.notify("[DAP] NL_PATH is not set", vim.log.levels.ERROR)
    return
  end
  local instance = os.getenv "INSTANCE" or "autotest"
  local args = { "javascript", "-instance:" .. instance }
  local env = maybe_engine_env()
  table.insert(args, "-file")
  table.insert(args, path)
  local cfg = {
    name    = "JavaScript" .. (path and path ~= "" and (" [" .. path .. "]") or ""),
    type    = "gdb",
    request = "launch",
    program = resolve_nlserver(),
    args    = args,
    cwd     = vim.fn.fnamemodify(nl, ":h"),
    env     = env,
  }
  _last_javascript_path = path
  _last_javascript_cfg = cfg
  require("dap").run(cfg)
end

function M.run_javascript()
  local path = vim.fn.input("JavaScript file: ", _last_javascript_path or "", "file")
  path = (path or ""):match("^%s*(.-)%s*$")
  if path == "" then return end
  _run_javascript(path)
end

function M.run_last_javascript()
  if not _last_javascript_cfg then
    vim.notify("[DAP] No previous JavaScript run – use <leader>dj first", vim.log.levels.WARN)
    return
  end
  require("dap").run(_last_javascript_cfg)
end

return M
