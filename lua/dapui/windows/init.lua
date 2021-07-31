local M = {}

local api = vim.api
local config = require("dapui.config")
local render = require("dapui.render")
local WindowLayout = require("dapui.windows.layout")

local float_windows = {}

---@type WindowLayout
M.sidebar = nil
---@type WindowLayout
M.tray = nil

local function setup_tray()
  local position = config.tray().position
  local height = config.tray().height
  local open_cmd = position == "top" and "topleft" or "botright"
  local function open_tray_win(index)
    vim.cmd(index == 1 and open_cmd .. " " .. height .. " split" or "vsplit")
  end

  local tray_elems = {}
  for _, win_config in pairs(config.tray().elements) do
    local exists, element = pcall(require, "dapui.elements." .. win_config.id)
    if exists then
      win_config.element = element
      tray_elems[#tray_elems + 1] = win_config
    else
      vim.notify("nvim-dap-ui: Element " .. win_config.id .. " does not exist")
    end
  end
  return WindowLayout(
    open_tray_win,
    api.nvim_win_get_width,
    function() end,
    tray_elems,
    render.loop
  )
end

local function setup_sidebar()
  local position = config.sidebar().position
  local width = config.sidebar().width
  local open_cmd = position == "left" and "topleft" or "botright"
  local function open_sidebar_win(index)
    vim.cmd(index == 1 and open_cmd .. " " .. width .. "vsplit" or "split")
  end

  local sidebar_elems = {}
  for _, win_config in pairs(config.sidebar().elements) do
    local exists, element = pcall(require, "dapui.elements." .. win_config.id)
    if exists then
      win_config.element = element
      sidebar_elems[#sidebar_elems + 1] = win_config
    else
      vim.notify("nvim-dap-ui: Element " .. win_config.id .. " does not exist")
    end
  end
  return WindowLayout(
    open_sidebar_win,
    api.nvim_win_get_height,
    api.nvim_win_set_height,
    sidebar_elems,
    render.loop
  )
end

function M.setup()
  M.tray = setup_tray()
  M.sidebar = setup_sidebar()
end

function M.open_float(element, position, settings)
  if float_windows[element.name] then
    float_windows[element.name]:jump_to()
    return float_windows[element.name]
  end
  local float_win = require("dapui.windows.float").open_float({
    height = settings.height or 1,
    width = settings.width or 1,
    position = position,
  })
  local buf = float_win:get_buf()
  render.loop.register_buffer(element.name, buf)
  local listener_id = element.name .. buf .. "float"
  render.loop.register_listener(
    listener_id,
    element.name,
    "render",
    function(rendered_buf, render_state)
      if rendered_buf == buf then
        float_win:resize(
          settings.width or render_state:width(),
          settings.height or render_state:length()
        )
      end
    end
  )
  render.loop.register_listener(listener_id, element.name, "close", function(closed_buf)
    if closed_buf == buf then
      render.loop.unregister_listener(listener_id, element.name, "render")
      render.loop.unregister_listener(listener_id, element.name, "close")
    end
  end)
  render.loop.run(element.name)
  vim.cmd(
    "au WinEnter,CursorMoved * ++once lua require('dapui.windows').close_float('"
      .. element.name
      .. "')"
  )
  float_win:listen("close", element.on_close)
  float_windows[element.name] = float_win
  if settings.enter then
    float_win:jump_to()
  end
  return float_win
end

function M.close_float(element_name)
  if float_windows[element_name] == nil then
    return
  end
  local win = float_windows[element_name]
  local buf = win:get_buf()
  local closed = win:close(false)
  if not closed then
    vim.cmd(
      "au WinEnter * ++once lua require('dapui.windows').close_float('" .. element_name .. "')"
    )
  else
    render.loop.remove_buffer(element_name, buf)
    float_windows[element_name] = nil
  end
end

return M
