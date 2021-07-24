local M = {}

local listener_id = "dapui"

local sidebar_open = true
local tray_open = true

local render = require("dapui.render")
local config = require("dapui.config")
local util = require("dapui.util")
local UIState = require("dapui.state")
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
  local line_no = vim.fn.screenrow()
  local col_no = vim.fn.screencol()
  local position = { line = line_no, col = col_no }
  open_float = require("dapui.windows").open_float(elem, position, {})
  open_float:listen("close", function()
    open_float = nil
  end)
end

function M.setup(user_config)
  local dap = require("dap")

  config.setup(user_config)
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
  if not component or component == "tray" then
    tray_open = false
    require("dapui.windows").close_tray()
  end
  if not component or component == "sidebar" then
    sidebar_open = false
    require("dapui.windows").close_sidebar()
  end
end

function M.open(component)
  if not component or component == "tray" then
    tray_open = true
    local tray_elems = {}
    for _, module in pairs(config.tray().elements) do
      tray_elems[#tray_elems + 1] = element(module)
    end
    require("dapui.windows").open_tray(tray_elems)
  end
  if not component or component == "sidebar" then
    sidebar_open = true
    local sidebar_elems = {}
    for _, module in pairs(config.sidebar().elements) do
      sidebar_elems[#sidebar_elems + 1] = element(module)
    end
    require("dapui.windows").open_sidebar(sidebar_elems)
  end
end

function M.toggle(component)
  if not component then
    M.toggle("tray")
    M.toggle("sidebar")
  end
  if component == "tray" then
    if tray_open then
      M.close(component)
    else
      M.open(component)
    end
  end
  if component == "sidebar" then
    if sidebar_open then
      M.close(component)
    else
      M.open(component)
    end
  end
end

return M
