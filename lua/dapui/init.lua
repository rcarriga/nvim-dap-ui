---@tag nvim-dap-ui
local dapui = {}

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

---Open a floating window containing the desired element.
---
---If no fixed dimensions are given, the window will expand to fit the contents
---of the buffer.
---@param elem_name string
---@param settings table
---@field width integer: Fixed width of window
---@field height integer: Fixed height of window
---@field enter boolean: Whether or not to enter the window after opening
function dapui.float_element(elem_name, settings)
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
      local settings = vim.tbl_deep_extend("keep", settings or {}, elem.float_defaults or {})
      open_float = require("dapui.windows").open_float(elem, position, settings)
      open_float:listen("close", function()
        open_float = nil
      end)
    end)
    if elem_name then
      with_elem(elem_name)
      return
    end
    query_elem_name(with_elem)
  end)
end

---Open a floating window containing the result of evaluting an expression
---
---If no fixed dimensions are given, the window will expand to fit the contents
---of the buffer.
---@param expr string: Expression to evaluate. If nil, then in normal more the current word is used, and in visual mode the currently highlighted text.
---@param settings table
---@field context string: Context to use for evalutate request, defaults to "hover". Hover requests should have no side effects, if you have errors with evaluation, try changing context to "repl". See the DAP specification for more details.
---@field width integer: Fixed width of window
---@field height integer: Fixed height of window
---@field enter boolean: Whether or not to enter the window after opening
function dapui.eval(expr, settings)
  settings = settings or {}
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
  elem.set_expression(expr, settings.context)
  vim.schedule(function()
    local line_no = vim.fn.screenrow()
    local col_no = vim.fn.screencol()
    local position = { line = line_no, col = col_no }
    open_float = require("dapui.windows").open_float(elem, position, settings)
    open_float:listen("close", function()
      open_float = nil
    end)
  end)
end

function dapui.setup(user_config)
  local dap = require("dap")
  local render = require("dapui.render")
  if ui_state then
    vim.notify("Setup called twice", "warn", {
      title = "nvim-dap-ui",
      icon = " ",
    })
  end
  render.loop.clear()

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
  ui_state:on_clear(function()
    render.loop.run()
  end)
end

local function keep_cmdheight(cb)
  local cmd_height = vim.o.cmdheight

  cb()

  vim.o.cmdheight = cmd_height
end

---Close one or all of the window layouts
---@param opts table
---@field layout number|nil: Index of layout in config
function dapui.close(opts)
  keep_cmdheight(function()
    opts = opts or {}
    if type(opts) == "number" then
      opts = { layout = opts }
    end
    local layout = opts.layout

    for _, win_layout in ipairs(windows.layouts) do
      win_layout:update_sizes()
    end
    for i, win_layout in ipairs(windows.layouts) do
      if not layout or layout == i then
        win_layout:update_sizes()
        win_layout:close()
      end
    end
  end)
end

---@generic T
---@param list T[]
---@return fun(): number, T
local function reverse(list)
  local i = #list + 1
  return function()
    i = i - 1
    if i <= 0 then
      return nil
    end
    return i, list[i]
  end
end

---Open one or all of the window layouts
---@param opts table
---@field layout number|nil: Index of layout in config
---@field reset boolean: Reset windows to original size
function dapui.open(opts)
  keep_cmdheight(function()
    opts = opts or {}
    if type(opts) == "number" then
      opts = { layout = opts }
    end
    local layout = opts.layout

    for _, win_layout in ipairs(windows.layouts) do
      win_layout:update_sizes()
    end
    local closed = {}
    if layout then
      for i = 1, (layout and layout - 1) or #windows.layouts, 1 do
        if windows.layouts[i]:is_open() then
          closed[#closed + 1] = i
          windows.layouts[i]:close()
        end
      end
    end

    for i, win_layout in reverse(windows.layouts) do
      if not layout or layout == i then
        win_layout:open()
      end
    end

    if #closed > 0 then
      for _, i in ipairs(closed) do
        windows.layouts[i]:open()
      end
    end

    for _, win_layout in ipairs(windows.layouts) do
      win_layout:resize(opts)
    end
  end)
end

---Toggle one or all of the window layouts.
---@param opts table
---@field layout number|nil: Index of layout in config
---@field reset boolean: Reset windows to original size
function dapui.toggle(opts)
  keep_cmdheight(function()
    opts = opts or {}
    if type(opts) == "number" then
      opts = { layout = opts }
    end
    local layout = opts.layout

    for _, win_layout in reverse(windows.layouts) do
      win_layout:update_sizes()
    end

    local closed = {}
    if layout then
      for i = 1, (layout and layout - 1) or #windows.layouts, 1 do
        if windows.layouts[i]:is_open() then
          closed[#closed + 1] = i
          windows.layouts[i]:close()
        end
      end
    end

    for i, win_layout in reverse(windows.layouts) do
      if not layout or layout == i then
        win_layout:toggle()
      end
    end

    for _, i in reverse(closed) do
      windows.layouts[i]:open()
    end

    for _, win_layout in ipairs(windows.layouts) do
      win_layout:resize(opts)
    end
  end)
end

return dapui
