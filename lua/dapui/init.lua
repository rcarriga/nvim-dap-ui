local M = {}

local listener_id = "dapui"

local windows = require("dapui.windows")
local config = require("dapui.config")
local ui_state

---@return Element
local function element(name)
  return require("dapui.elements." .. name)
end

local open_float = nil

local function query_elem_name()
  if open_float then
    return open_float
  end
  local entries = { "Select an element:" }
  local elems = {}
  for _, name in pairs(config.elements) do
    if name ~= config.elements.HOVER then
      entries[#entries + 1] = tostring(#entries) .. ": " .. name
      elems[#elems + 1] = name
    end
  end
  return elems[vim.fn.inputlist(entries)]
end

function M.float_element(elem_name)
  vim.schedule(function()
    local line_no = vim.fn.screenrow()
    local col_no = vim.fn.screencol()
    local position = { line = line_no, col = col_no }
    elem_name = elem_name or query_elem_name()
    if not elem_name then
      return
    end
    open_float = elem_name
    local elem = element(elem_name)
    local win = require("dapui.windows").open_float(elem, position, elem.float_defaults or {})
    win:listen("close", function()
      open_float = nil
    end)
  end)
end

function M.eval(expr)
  if open_float then
    open_float:jump_to()
    return
  end
  if not expr then
    if vim.fn.mode() == "v" then
      local start = vim.fn.getpos("v")
      local finish = vim.fn.getpos(".")
      local lines = require("dapui.util").get_selection(start, finish)
      expr = table.concat(lines, "\n")
    else
      expr = expr or vim.fn.expand("<cexpr>")
    end
  end
  local elem = require("dapui.elements.hover")
  elem.set_expression(expr)
  vim.schedule(function()
    local line_no = vim.fn.screenrow()
    local col_no = vim.fn.screencol()
    local position = { line = line_no, col = col_no }
    open_float = require("dapui.windows").open_float(elem, position, {})
    open_float:listen("close", function()
      open_float = nil
    end)
  end)
end

function M.setup(user_config)
  local dap = require("dap")
  local render = require("dapui.render")

  config.setup(user_config)

  local UIState = require("dapui.state")
  ui_state = UIState()
  ui_state:attach(dap)

  for _, module in pairs(config.elements) do
    local elem = element(module)
    elem.setup(ui_state)
    render.loop.register_element(elem)
    for _, event in pairs(elem.dap_after_listeners or {}) do
      dap.listeners.after[event]["DapUI " .. elem.name] = function()
        render.loop.run(elem.name)
      end
    end
  end

  windows.setup()

  ui_state:on_refresh(function()
    render.loop.run()
  end)

  dap.listeners.after.event_initialized[listener_id] = function()
    if config.tray().open_on_start then
      M.open("tray")
    end
    if config.sidebar().open_on_start then
      M.open("sidebar")
    end
  end

  dap.listeners.before.event_terminated[listener_id] = function()
    M.close()
  end

  dap.listeners.before.event_exited[listener_id] = function()
    M.close()
  end
end

function M.close(component)
  windows.tray:update_sizes()
  windows.sidebar:update_sizes()
  if not component or component == "tray" then
    windows.tray:update_sizes()
    windows.tray:close()
  end
  if not component or component == "sidebar" then
    windows.sidebar:update_sizes()
    windows.sidebar:close()
  end
end

function M.open(component)
  windows.tray:update_sizes()
  windows.sidebar:update_sizes()
  local open_sidebar = false
  if component == "tray" and windows.sidebar:is_open() then
    windows.sidebar:close()
    open_sidebar = true
  end
  if not component or component == "tray" then
    windows.tray:open()
  end
  if not component or component == "sidebar" then
    windows.sidebar:open()
  end
  if open_sidebar then
    windows.sidebar:open()
  end
end

function M.toggle(component)
  windows.tray:update_sizes()
  windows.sidebar:update_sizes()
  local open_sidebar = false
  if component == "tray" and windows.sidebar:is_open() then
    windows.sidebar:close()
    open_sidebar = true
  end
  if not component or component == "tray" then
    windows.tray:toggle()
  end
  if not component or component == "sidebar" then
    windows.sidebar:toggle()
  end
  if open_sidebar then
    windows.sidebar:open()
  end
end

return M
