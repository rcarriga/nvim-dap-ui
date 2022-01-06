local M = {}

local windows = require("dapui.windows")
local config = require("dapui.config")
local ui_state

---@return Element
local function element(name)
  return require("dapui.elements." .. name)
end

local open_float = nil

local function query_elem_name(on_select)
  local entries = {}
  local elems = {}
  for _, name in pairs(config.elements) do
    if name ~= config.elements.HOVER then
      entries[#entries + 1] = name
      elems[#elems + 1] = name
    end
  end
  vim.ui.select(entries, {
    prompt = "Select an element:",
    format_item = function(entry)
      return entry:sub(1, 1):upper() .. entry:sub(2)
    end,
  }, on_select)
end

function M.float_element(elem_name, user_settings)
  vim.schedule(function()
    if open_float then
      return open_float:jump_to()
    end
    local line_no = vim.fn.screenrow()
    local col_no = vim.fn.screencol()
    local position = { line = line_no, col = col_no }
    local with_elem = vim.schedule_wrap(function(elem_name)
      if not elem_name then
        return
      end
      local elem = element(elem_name)
      local settings = vim.tbl_deep_extend("keep", user_settings or {}, elem.float_defaults or {})
      open_float = require("dapui.windows").open_float(elem, position, settings)
      open_float:listen("close", function()
        open_float = nil
      end)
    end)
    if elem_name then
      with_elem(elem_name)
    end
    query_elem_name(with_elem)
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
  windows.tray:resize()
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
  windows.tray:resize()
end

return M
