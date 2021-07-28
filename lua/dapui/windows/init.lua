local M = {}

local config = require("dapui.config")
local render = require("dapui.render")

local float_windows = {}
local sidebar_windows = {}
local tray_windows = {}

local function init_win_settings(win)
  local win_settings = {
    list = false,
    relativenumber = false,
    number = false,
    winfixwidth = true,
    wrap = false,
  }
  for key, val in pairs(win_settings) do
    vim.api.nvim_win_set_option(win, key, val)
  end
end

local function open_wins(elements, open, saved)
  local cur_win = vim.api.nvim_get_current_win()
  for i, element in pairs(elements) do
    local win_id = vim.fn["bufwinid"](element.name)
    if win_id == -1 then
      local buf = vim.api.nvim_create_buf(false, true)
      open(i)
      win_id = vim.api.nvim_get_current_win()
      vim.api.nvim_set_current_buf(buf)
      saved[win_id] = element
    end
    local bufnr = vim.api.nvim_win_get_buf(win_id)
    render.loop.register_buffer(element.name, bufnr)
    init_win_settings(win_id)
    render.loop.run(element.name)
  end
  vim.api.nvim_set_current_win(cur_win)
end

local function close_wins(saved)
  local current_win = vim.api.nvim_get_current_win()
  for win, _ in pairs(saved) do
    local win_exists, buf = pcall(vim.api.nvim_win_get_buf, win)
    if win_exists then
      if win == current_win then
        vim.cmd("stopinsert") -- Prompt buffers act poorly when closed in insert mode, see #33
      end
      pcall(vim.api.nvim_win_close, win, true)
      vim.api.nvim_buf_delete(buf, { force = true, unload = false })
    end
  end
end

function M.open_sidebar(elements)
  local position = config.sidebar().position
  local width = config.sidebar().width
  local open_cmd = position == "left" and "topleft" or "botright"
  local function open_sidebar_win(index)
    vim.cmd(index == 1 and open_cmd .. " " .. width .. "vsplit" or "split")
  end

  open_wins(elements, open_sidebar_win, sidebar_windows)
end

function M.open_tray(elements)
  local position = config.tray().position
  local height = config.tray().height
  local open_cmd = position == "top" and "topleft" or "botright"
  local function open_tray_win(index)
    vim.cmd(index == 1 and open_cmd .. " " .. height .. " split" or "vsplit")
  end
  open_wins(elements, open_tray_win, tray_windows)
end

function M.close_sidebar()
  close_wins(sidebar_windows)
  sidebar_windows = {}
end

function M.close_tray()
  close_wins(tray_windows)
  tray_windows = {}
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
