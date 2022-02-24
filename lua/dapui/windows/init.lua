local M = {}

local api = vim.api
local util = require("dapui.util")
local config = require("dapui.config")
local render = require("dapui.render")
local WindowLayout = require("dapui.windows.layout")

local float_windows = {}

---@type dapui.WindowLayout
M.sidebar = nil
---@type dapui.WindowLayout
M.tray = nil

local function register_elements(elements)
  local win_configs = {}
  for _, win_config in pairs(elements) do
    local exists, element = pcall(require, "dapui.elements." .. win_config.id)
    if exists then
      win_config.element = element
      win_configs[#win_configs + 1] = win_config
    else
      vim.notify("nvim-dap-ui: Element " .. win_config.id .. " does not exist")
    end
  end
  return win_configs
end

local function tray_layout(height, position, win_configs)
  local open_cmd = position == "top" and "topleft" or "botright"

  local function open_tray_win(index)
    vim.cmd(index == 1 and open_cmd .. " " .. " split" or "vsplit")
  end

  return WindowLayout({
    area_state = { size = height },
    win_states = win_configs,
    get_win_size = api.nvim_win_get_width,
    get_area_size = api.nvim_win_get_height,
    set_win_size = api.nvim_win_set_width,
    set_area_size = api.nvim_win_set_height,
    open_index = open_tray_win,
    loop = render.loop,
  })
end

local function side_layout(width, position, win_configs)
  local open_cmd = position == "left" and "topleft" or "botright"
  local function open_side_win(index)
    vim.cmd(index == 1 and open_cmd .. " " .. "vsplit" or "split")
  end

  return WindowLayout({
    area_state = { size = width },
    win_states = win_configs,
    get_win_size = api.nvim_win_get_height,
    get_area_size = api.nvim_win_get_width,
    set_area_size = api.nvim_win_set_width,
    set_win_size = api.nvim_win_set_height,
    open_index = open_side_win,
    loop = render.loop,
  })
end

local function area_layout(size, position, elements)
  local win_configs = register_elements(elements)
  local layout_func
  if position == "top" or position == "bottom" then
    layout_func = tray_layout
  else
    layout_func = side_layout
  end
  return layout_func(size, position, win_configs)
end

function M.setup()
  local tray_config = config.tray()
  M.tray = area_layout(tray_config.size, tray_config.position, tray_config.elements)
  local sidebar_config = config.sidebar()
  M.sidebar = area_layout(sidebar_config.size, sidebar_config.position, sidebar_config.elements)
  vim.cmd([[
    augroup DapuiWindowsSetup
      au!
      au BufWinEnter,BufWinLeave * lua require('dapui.windows')._force_buffers()
    augroup END
  ]])
end

function M._force_buffers()
  M.tray:force_buffers()
  M.sidebar:force_buffers()
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
  render.loop.register_listener(listener_id, element.name, "render", function(rendered_buf, canvas)
    if rendered_buf == buf then
      float_win:resize(settings.width or canvas:width(), settings.height or canvas:length())
    end
  end)
  render.loop.register_listener(listener_id, element.name, "close", function(closed_buf)
    if closed_buf == buf then
      render.loop.unregister_listener(listener_id, element.name, "render")
      render.loop.unregister_listener(listener_id, element.name, "close")
    end
  end)
  render.loop.run(element.name)
  local updated_buf = float_win:get_buf()
  util.apply_mapping(
    config.floating().mappings[config.FLOAT_MAPPINGS.CLOSE],
    "<Cmd>q<CR>",
    updated_buf
  )
  local close_cmd = "lua require('dapui.windows').close_float('" .. element.name .. "')"
  vim.cmd("au WinEnter,CursorMoved * ++once " .. close_cmd)
  vim.cmd("au WinClosed " .. float_win.win_id .. " ++once " .. close_cmd)
  float_win:listen("close", function()
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
  end)
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
    local close_cmd = "lua require('dapui.windows').close_float('" .. element_name .. "')"
    vim.cmd("au WinEnter * ++once " .. close_cmd)
    vim.cmd("au WinClosed " .. win.win_id .. " ++once " .. close_cmd)
  else
    render.loop.remove_buffer(element_name, buf)
    float_windows[element_name] = nil
  end
end

return M
