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
--- ```lua
---   require("neodev").setup({
---     library = { plugins = { "nvim-dap-ui" }, types = true },
---     ...
---   })
--- ```
---
--- The default icons use codicons(https://github.com/microsoft/vscode-codicons).
--- It's recommended to use this fork(https://github.com/ChristianChiarulli/neovim-codicons)
--- which fixes alignment issues for the terminal. If your terminal doesn't
--- support font fallback and you need to have icons included in your font,
--- you can patch it via Font Patcher(https://github.com/ryanoasis/nerd-fonts#option-8-patch-your-own-font).
--- There is a simple step by step guide here: https://github.com/mortepau/codicons.nvim#how-to-patch-fonts.

local success, _ = pcall(require, "nio")
if not success then
  error(
    "nvim-dap-ui requires nvim-nio to be installed. Install from https://github.com/nvim-neotest/nvim-nio"
  )
end

local dap = require("dap")

---@class dapui
---@nodoc
local dapui = {}

local windows = require("dapui.windows")
local config = require("dapui.config")
local util = require("dapui.util")
local nio = require("nio")
local controls = require("dapui.controls")

---@type table<string, dapui.Element>
---@nodoc
local elements = {}

local open_float = nil

local function query_elem_name()
  local entries = {}
  for name, _ in pairs(elements) do
    if name ~= "hover" then
      entries[#entries + 1] = name
    end
  end
  return nio.ui.select(entries, {
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
  util.stop_render_tasks()

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
    local existing_elem = elements[module]
    if existing_elem then
      local buffer = existing_elem.buffer()
      if vim.api.nvim_buf_is_valid(buffer) then
        vim.api.nvim_buf_delete(buffer, { force = true })
      end
    end
    ---@type dapui.Element
    local elem = require("dapui.elements." .. module)(client)

    elements[module] = elem
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
---@field title string Title of window
---@field position "center" Position of floating window

--- Open a floating window containing the desired element.
---
--- If no fixed dimensions are given, the window will expand to fit the contents
--- of the buffer.
---@param elem_name string
---@param args? dapui.FloatElementArgs
function dapui.float_element(elem_name, args)
  nio.run(function()
    elem_name = elem_name or query_elem_name()
    if not elem_name then
      return
    end
    local elem = elements[elem_name]
    if not elem then
      util.notify("No such element: " .. elem_name, vim.log.levels.ERROR)
      return
    end
    if not elem.allow_without_session and not dap.session() then
      util.notify("No active debug session", vim.log.levels.WARN)
      return
    end
    if open_float then
      return open_float:jump_to()
    end
    local line_no = nio.fn.screenrow()
    local col_no = nio.fn.screencol()
    local position = { line = line_no, col = col_no }
    elem.render()
    args = vim.tbl_deep_extend(
      "keep",
      args or {},
      elem.float_defaults and elem.float_defaults() or {},
      { title = elem_name }
    )
    nio.scheduler()
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
---@param expr? string Expression to evaluate. If nil, then in normal more the
--- current word is used, and in visual mode the currently highlighted text.
---@param args? dapui.EvalArgs
function dapui.eval(expr, args)
  nio.run(function()
    if not dap.session() then
      util.notify("No active debug session", vim.log.levels.WARN)
      return
    end
    args = args or {}
    if not expr then
      expr = util.get_current_expr()
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
    local win_pos = nio.api.nvim_win_get_position(0)
    local position = {
      line = win_pos[1] + nio.fn.winline(),
      col = win_pos[2] + nio.fn.wincol() - 1,
    }
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
  nio.run(function()
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
  dapui.update_render({})
  if config.controls.enabled and config.controls.element ~= "" then
    controls.enable_controls(elements[config.controls.element])
  end
  controls.refresh_control_panel()
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
  dapui.update_render({})
  if config.controls.enabled and config.controls.element ~= "" then
    controls.enable_controls(elements[config.controls.element])
  end
  controls.refresh_control_panel()
end

---@text
--- Access the elements currently registered. See elements corresponding help
--- tag for API information.
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
---@field allow_without_session boolean Allows floating the element when
--- there is no active debug session

--- Registers a new element that can be used within layouts or floating windows
---@param name string Name of the element
---@param element dapui.Element
function dapui.register_element(name, element)
  if elements[name] then
    error("Element " .. name .. " already exists")
  end
  elements[name] = element
  windows.register_element(name, element)
  nio.run(function()
    element.render()
  end)
end

return dapui
