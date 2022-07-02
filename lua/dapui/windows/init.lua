local M = {}

local api = vim.api
local util = require("dapui.util")
local config = require("dapui.config")
local render = require("dapui.render")
local WindowLayout = require("dapui.windows.layout")

local float_windows = {}

---@type dapui.WindowLayout[]
M.layouts = {}

local function create_win_states(win_configs)
  local win_states = {}
  for _, win_state in pairs(win_configs) do
    local exists, element = pcall(require, "dapui.elements." .. win_state.id)
    if exists then
      win_state.element = element
      win_state.init_size = win_state.size
      win_states[#win_states + 1] = win_state
    else
      vim.notify("nvim-dap-ui: Element " .. win_state.id .. " does not exist")
    end
  end
  return win_states
end

local function horizontal_layout(height, position, win_configs)
  local open_cmd = position == "top" and "topleft" or "botright"

  local function open_tray_win(index)
    vim.cmd(index == 1 and open_cmd .. " " .. " split" or "vsplit")
  end

  return WindowLayout({
    layout_type = "horizontal",
    area_state = { size = height, init_size = height },
    win_states = win_configs,
    get_win_size = api.nvim_win_get_width,
    get_area_size = api.nvim_win_get_height,
    set_win_size = api.nvim_win_set_width,
    set_area_size = api.nvim_win_set_height,
    open_index = open_tray_win,
    loop = render.loop,
  })
end

local function vertical_layout(width, position, win_configs)
  local open_cmd = position == "left" and "topleft" or "botright"
  local function open_side_win(index)
    vim.cmd(index == 1 and open_cmd .. " " .. "vsplit" or "split")
  end

  return WindowLayout({
    layout_type = "vertical",
    area_state = { size = width, init_size = width },
    win_states = win_configs,
    get_win_size = api.nvim_win_get_height,
    get_area_size = api.nvim_win_get_width,
    set_area_size = api.nvim_win_set_width,
    set_win_size = api.nvim_win_set_height,
    open_index = open_side_win,
    loop = render.loop,
  })
end

local function area_layout(size, position, win_configs)
  local win_states = create_win_states(win_configs)
  local layout_func
  if position == "top" or position == "bottom" then
    layout_func = horizontal_layout
  else
    layout_func = vertical_layout
  end
  return layout_func(size, position, win_states)
end

function M.setup()
  for _, layout in ipairs(M.layouts) do
    layout:close()
  end
  local layout_configs = config.layouts()
  M.layouts = {}
  for i, layout in ipairs(layout_configs) do
    M.layouts[i] = area_layout(layout.size, layout.position, layout.elements)
  end
  vim.cmd([[
    augroup DapuiWindowsSetup
      au!
      au BufWinEnter,BufWinLeave * lua require('dapui.windows')._force_buffers()
    augroup END
  ]])
end

function M._force_buffers()
  for _, layout in ipairs(M.layouts) do
    layout:force_buffers()
  end
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
