---@tag nvim-dap-ui

local dap = require("dap")
local dapui = {}

local windows = require("dapui.windows")
local config = require("dapui.config")
local util = require("dapui.util")
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

local prev_expr = nil

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
  if not dap.session() then
    util.notify("No active debug session", vim.log.levels.WARN)
    return
  end
  settings = settings or {}
  if not expr then
    if vim.fn.mode() == "v" then
      local start = vim.fn.getpos("v")
      local finish = vim.fn.getpos(".")
      local lines = util.get_selection(start, finish)
      expr = table.concat(lines, "\n")
    else
      expr = expr or vim.fn.expand("<cexpr>")
    end
  end
  if open_float then
    if prev_expr == expr then
      open_float:jump_to()
      return
    else
      open_float:close()
    end
  end
  prev_expr = expr
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

function dapui._dump_state()
  local data = vim.inspect(ui_state)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(data, "\n"))
  vim.cmd("sb " .. buf)
end

local refresh_control_panel = function() end

function dapui.setup(user_config)
  local render = require("dapui.render")
  if ui_state then
    util.notify("Setup called twice", vim.log.levels.DEBUG)
  end
  render.loop.clear()

  config.setup(user_config)

  local UIState = require("dapui.state")
  ui_state = UIState()
  ui_state:attach(dap)

  local buf_name_map = {}
  for _, module in pairs(config.elements) do
    local elem = element(module)
    buf_name_map[module] = elem.name ~= "DAP REPL" and elem.name or "\\[dap-repl\\]"
    elem.setup(ui_state)
    render.loop.register_element(elem)
    for _, event in pairs(elem.dap_after_listeners or {}) do
      dap.listeners.after[event]["DapUI " .. elem.name] = function()
        render.loop.run(elem.name)
      end
    end
  end

  if config.controls.enabled and config.controls.element ~= "" then
    local buf_name = buf_name_map[config.controls.element]

    local group = vim.api.nvim_create_augroup("DAPUIControls", {})
    local win

    refresh_control_panel = function()
      if win then
        if not pcall(vim.api.nvim_win_set_option, win, "winbar", dapui.controls()) then
          win = nil
        end
      end
    end

    local list_id = "dapui_controls"
    local events = {
      "event_terminated",
      "disconnect",
      "event_exited",
      "event_stopped",
      "threads",
      "event_continued",
    }
    for _, event in ipairs(events) do
      dap.listeners.after[event][list_id] = refresh_control_panel
    end

    local cb = function(opts)
      if win then
        return
      end

      win = vim.fn.bufwinid(opts.buf)
      if win == -1 then
        win = nil
        return
      end
      refresh_control_panel()
      vim.api.nvim_create_autocmd({ "WinClosed", "BufWinLeave" }, {
        group = group,
        callback = function()
          if win and not vim.api.nvim_win_is_valid(win) then
            win = nil
          end
        end,
      })
    end
    vim.api.nvim_create_autocmd({ "FileType" }, {
      pattern = element(config.controls.element).buf_options.filetype,
      group = group,
      callback = cb,
    })
    vim.api.nvim_create_autocmd("BufWinEnter", {
      pattern = buf_name,
      group = group,
      callback = cb,
    })
  end

  windows.setup()

  ui_state:on_refresh(function()
    render.loop.run()
  end)
  ui_state:on_clear(function()
    render.loop.run()
  end)
end

---Update the config.render settings and re-render windows
---@param update table: Updated settings, from the `render` table of the config
function dapui.update_render(update)
  config.update_render(update)
  local render = require("dapui.render")
  render.loop.run()
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
  refresh_control_panel()
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
  refresh_control_panel()
end

_G._dapui = {
  play = function()
    local session = dap.session()
    if not session or session.stopped_thread_id then
      dap.continue()
    else
      dap.pause()
    end
  end,
}
setmetatable(_dapui, {
  __index = function(_, key)
    return function()
      return dap[key]()
    end
  end,
})

function dapui.controls()
  local session = dap.session()

  local running = (session and not session.stopped_thread_id)

  local avail_hl = function(group, allow_running)
    if not session or (not allow_running and running) then
      return "DapUIUnavailable"
    end
    return group
  end

  local icons = config.controls.icons
  local elems = {
    {
      func = "play",
      icon = running and icons.pause or icons.play,
      hl = "DapUIPlayPause",
    },
    { func = "step_into", hl = avail_hl("DapUIStepInto") },
    { func = "step_over", "", hl = avail_hl("DapUIStepOver") },
    { func = "step_out", "", hl = avail_hl("DapUIStepOut") },
    { func = "step_back", "", hl = avail_hl("DapUIStepBack") },
    { func = "run_last", "", hl = "DapUIRestart" },
    { func = "terminate", "", hl = avail_hl("DapUIStop", true) },
  }
  local bar = ""
  for _, elem in ipairs(elems) do
    bar = bar
      .. ("  %%#%s#%%0@v:lua._dapui.%s@%s%%#0#"):format(
        elem.hl,
        elem.func,
        elem.icon or icons[elem.func]
      )
  end
  return bar
end

return dapui
