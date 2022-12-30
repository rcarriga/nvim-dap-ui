---@tag nvim-dap-ui

---@toc
---@text
--- A UI for nvim-dap which provides a good out of the box configuration.
--- nvim-dap-ui is built on the idea of "elements". These elements are windows
--- which provide different features.
--- Elements are grouped into layouts which can be placed on any side of the
--- screen. There can be any number of layouts, containing whichever elements
--- desired.
---
--- Elements can also be displayed temporarily in a floating window.
---
--- See `:h dapui.setup()` for configuration options and defaults
---
--- It is highly recommended to use neodev.nvim to enable type checking for
--- nvim-dap-ui to get type checking, documentation and autocompletion for
--- all API functions.
---
--- >lua
---   require("neodev").setup({
---     library = { plugins = { "nvim-dap-ui" }, types = true },
---     ...
---   })
--- <
---
--- The default icons use codicons(https://github.com/microsoft/vscode-codicons).
--- It's recommended to use this fork(https://github.com/ChristianChiarulli/neovim-codicons)
--- which fixes alignment issues for the terminal. If your terminal doesn't
--- support font fallback and you need to have icons included in your font,
--- you can patch it via Font Patcher(https://github.com/ryanoasis/nerd-fonts#option-8-patch-your-own-font).
--- There is a simple step by step guide here: https://github.com/mortepau/codicons.nvim#how-to-patch-fonts.

local dap = require("dap")

---@class dapui
---@nodoc
local dapui = {}

local windows = require("dapui.windows")
local config = require("dapui.config")
local util = require("dapui.util")
local async = require("dapui.async")

dapui.async = async

---@type table<string, dapui.Element>
---@nodoc
local elements = {}

local open_float = nil

local refresh_control_panel = function() end

local function query_elem_name()
  local entries = {}
  for name, _ in pairs(elements) do
    if name ~= "hover" then
      entries[#entries + 1] = name
    end
  end
  return async.ui.select(entries, {
    prompt = "Select an element:",
    format_item = function(entry)
      return entry:sub(1, 1):upper() .. entry:sub(2)
    end,
  })
end

---@toc_entry Setup
---@text
--- Configure nvim-dap-ui
---@seealso |dapui.Config|
---
---@eval return require('dapui.config')._format_default()
---@param user_config? dapui.Config
function dapui.setup(user_config)
  config.setup(user_config)

  local client = require("dapui.client")(dap.session)

  ---@type table<string, dapui.Element>
  for _, module in pairs({
    "breakpoints",
    "repl",
    "scopes",
    "stacks",
    "watches",
    "hover",
    "console",
  }) do
    local elem = require("dapui.elements." .. module)(client)

    elements[module] = elem
  end

  if config.controls.enabled and config.controls.element ~= "" then
    local buffer = elements[config.controls.element].buffer()

    local group = vim.api.nvim_create_augroup("DAPUIControls", {})
    local win

    refresh_control_panel = function()
      if win then
        local is_current = win == vim.fn.win_getid()
        if not pcall(vim.api.nvim_win_set_option, win, "winbar", dapui.controls(is_current)) then
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
        buffer = buffer,
        callback = function()
          if win and not vim.api.nvim_win_is_valid(win) then
            win = nil
          end
        end,
      })
    end
    vim.api.nvim_create_autocmd("BufWinEnter", {
      buffer = buffer,
      group = group,
      callback = cb,
    })
    vim.api.nvim_create_autocmd("WinEnter", {
      buffer = buffer,
      group = group,
      callback = function()
        local winbar = dapui.controls(true)
        vim.api.nvim_win_set_option(vim.api.nvim_get_current_win(), "winbar", winbar)
      end,
    })
    vim.api.nvim_create_autocmd("WinLeave", {
      buffer = buffer,
      group = group,
      callback = function()
        local winbar = dapui.controls(false)
        vim.api.nvim_win_set_option(vim.api.nvim_get_current_win(), "winbar", winbar)
      end,
    })
  end

  local element_buffers = {}
  for name, elem in pairs(elements) do
    element_buffers[name] = elem.buffer
  end
  windows.setup(element_buffers)
end

---@class dapui.FloatElementArgs
---@field width integer Fixed width of window
---@field height integer Fixed height of window
---@field enter boolean Whether or not to enter the window after opening

--- Open a floating window containing the desired element.
---
--- If no fixed dimensions are given, the window will expand to fit the contents
--- of the buffer.
---@param elem_name string
---@param args? dapui.FloatElementArgs
function dapui.float_element(elem_name, args)
  async.run(function()
    if open_float then
      return open_float:jump_to()
    end
    local line_no = async.fn.screenrow()
    local col_no = async.fn.screencol()
    local position = { line = line_no, col = col_no }
    elem_name = elem_name or query_elem_name()
    if not elem_name then
      return
    end
    local elem = elements[elem_name]
    args =
      vim.tbl_deep_extend("keep", args or {}, elem.float_defaults and elem.float_defaults() or {})
    async.scheduler()
    open_float = require("dapui.windows").open_float(elem_name, elem, position, args)
    if open_float then
      open_float:listen("close", function()
        open_float = nil
      end)
    end
  end)
end

local prev_expr = nil

---@class dapui.EvalArgs
---@field context string Context to use for evalutate request, defaults to
--- "hover". Hover requests should have no side effects, if you have errors
--- with evaluation, try changing context to "repl". See the DAP specification
--- for more details.
---@field width integer Fixed width of window
---@field height integer Fixed height of window
---@field enter boolean Whether or not to enter the window after opening

--- Open a floating window containing the result of evaluting an expression
---
--- If no fixed dimensions are given, the window will expand to fit the contents
--- of the buffer.
---@param expr string Expression to evaluate. If nil, then in normal more the
--- current word is used, and in visual mode the currently highlighted text.
---@param args dapui.EvalArgs
function dapui.eval(expr, args)
  async.run(function()
    if not dap.session() then
      util.notify("No active debug session", vim.log.levels.WARN)
      return
    end
    args = args or {}
    if not expr then
      if vim.fn.mode() == "v" then
        local start = async.fn.getpos("v")
        local finish = async.fn.getpos(".")
        local lines = util.get_selection(start, finish)
        expr = table.concat(lines, "\n")
      else
        expr = expr or async.fn.expand("<cexpr>")
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
    local elem = dapui.elements.hover
    elem.set_expression(expr, args.context)
    local line_no = async.fn.screenrow()
    local col_no = async.fn.screencol()
    local position = { line = line_no, col = col_no }
    open_float = require("dapui.windows").open_float("hover", elem, position, args)
    if open_float then
      open_float:listen("close", function()
        open_float = nil
      end)
    end
  end)
end

--- Update the config.render settings and re-render windows
---@param update dapui.Config.render Updated settings, from the `render` table of
--- the config
function dapui.update_render(update)
  config.update_render(update)
  async.run(function()
    for _, elem in pairs(elements) do
      elem.render()
    end
  end)
end

local function keep_cmdheight(cb)
  local cmd_height = vim.o.cmdheight

  cb()

  vim.o.cmdheight = cmd_height
end

---@class dapui.CloseArgs
---@field layout? number Index of layout in config

--- Close one or all of the window layouts
---@param args? dapui.CloseArgs
function dapui.close(args)
  keep_cmdheight(function()
    args = args or {}
    if type(args) == "number" then
      args = { layout = args }
    end
    local layout = args.layout

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
---@nodoc
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

---@class dapui.OpenArgs
---@field layout? number Index of layout in config
---@field reset? boolean Reset windows to original size

--- Open one or all of the window layouts
---@param args? dapui.OpenArgs
function dapui.open(args)
  keep_cmdheight(function()
    args = args or {}
    if type(args) == "number" then
      args = { layout = args }
    end
    local layout = args.layout

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
      win_layout:resize(args)
    end
  end)
  refresh_control_panel()
end

---@class dapui.ToggleArgs
---@field layout? number Index of layout in config
---@field reset? boolean Reset windows to original size

--- Toggle one or all of the window layouts.
---@param args? dapui.ToggleArgs
function dapui.toggle(args)
  keep_cmdheight(function()
    args = args or {}
    if type(args) == "number" then
      args = { layout = args }
    end
    local layout = args.layout

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
      win_layout:resize(args)
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

---@text
--- Access the elements currently registered. See elements corresponding help
--- tag for API information.
---
--- Most API functions are asynchronous, meaning that they must be run within an
--- async context. This can be done by wrapping the function in `async.run`.
--- >lua
---   local dapui = require("dapui")
---   dapui.async.run(function()
---     dapui.elements.watches.add("some_variable")
---   end)
--- <
---
---@class dapui.elements
---@field hover dapui.elements.hover
---@field breakpoints dapui.elements.breakpoints
---@field repl dapui.elements.repl
---@field scopes dapui.elements.scopes
---@field stack dapui.elements.stacks
---@field watches dapui.elements.watches
---@field console dapui.elements.console
dapui.elements = setmetatable({}, {
  __newindex = function()
    error("Elements should be registered instead of adding them to the elements table")
  end,
  __index = function(_, key)
    return elements[key]
  end,
})

---@class dapui.Element
---@field render fun() Triggers the element to refresh its buffer. Used when
--- render settings have changed
---@field buffer fun(): integer Gets the current buffer for the element. The
--- buffer can change over repeated calls
---@field float_defaults? fun(): dapui.FloatElementArgs Default settings for
--- floating windows. Useful for element windows which should be larger than
--- their content

--- Registers a new element that can be used within layouts or floating windows
---@param name string Name of the element
---@param element dapui.Element
function dapui.register_element(name, element)
  if elements[name] then
    error("Element " .. name .. " already exists")
  end
  elements[name] = element
end

function dapui.controls(is_active)
  local session = dap.session()

  local running = (session and not session.stopped_thread_id)

  local avail_hl = function(group, allow_running)
    if not session or (not allow_running and running) then
      return is_active and "DapUIUnavailable" or "DapUIUnavailableNC"
    end
    return group
  end

  local icons = config.controls.icons
  local elems = {
    {
      func = "play",
      icon = running and icons.pause or icons.play,
      hl = is_active and "DapUIPlayPause" or "DapUIPlayPauseNC",
    },
    { func = "step_into", hl = avail_hl(is_active and "DapUIStepInto" or "DapUIStepIntoNC") },
    { func = "step_over", hl = avail_hl(is_active and "DapUIStepOver" or "DapUIStepOverNC") },
    { func = "step_out", hl = avail_hl(is_active and "DapUIStepOut" or "DapUIStepOutNC") },
    { func = "step_back", hl = avail_hl(is_active and "DapUIStepBack" or "DapUIStepBackNC") },
    { func = "run_last", hl = is_active and "DapUIRestart" or "DapUIRestartNC" },
    { func = "terminate", hl = avail_hl(is_active and "DapUIStop" or "DapUIStopNC", true) },
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
