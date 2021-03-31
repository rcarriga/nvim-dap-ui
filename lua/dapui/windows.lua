local M = {}

vim.cmd("hi default DapUIFloatBorder guifg=#00F1F5")
local float_windows = {}
local sidebar_windows = {}
local tray_windows = {}

local function init_win_settings(win)
  local win_settings = {
    list = false,
    relativenumber = false,
    number = false,
    winfixwidth = true
  }
  for key, val in pairs(win_settings) do
    vim.api.nvim_win_set_option(win, key, val)
  end
end

local function open_sidebar_win(index)
  vim.cmd(index == 1 and "botright 60vsplit" or "split")
end

local function open_tray_win(index)
  vim.cmd(index == 1 and "botright 15split" or "vsplit")
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
    local bufnr = vim.fn.winbufnr(win_id)
    element.on_open(
      bufnr,
      function(render_state)
        render_state:render_buffer(bufnr)
      end
    )
    init_win_settings(win_id)
  end
  vim.api.nvim_set_current_win(cur_win)
end

local function close_wins(saved)
  for win, element in pairs(saved) do
    local buf = vim.fn.winbufnr(win)
    vim.api.nvim_win_close(win, true)
    element.on_close({buffer = buf})
  end
end

function M.open_sidebar(elements)
  open_wins(elements, open_sidebar_win, sidebar_windows)
end

function M.open_tray(elements)
  open_wins(elements, open_tray_win, tray_windows)
end

function M.close_sidebar()
  close_wins(sidebar_windows)
end

function M.close_tray()
  close_wins(tray_windows)
end

function M.open_float(element, position, settings)
  if float_windows[element.name] then
    float_windows[element.name]:jump_to()
    return float_windows[element.name]
  end
  local float_win = require("dapui.windows.float").open_float({height = 1, width = 1, position = position})
  local buf = float_win:get_buf()
  vim.fn.setbufvar(buf, "&filetype", element.buf_settings.filetype)
  element.on_open(
    buf,
    function(render_state)
      local rendered = render_state:render_buffer(float_win:get_buf())
      if rendered then
        float_win:resize(settings.width or render_state:width(), settings.height or render_state:length())
      end
    end
  )
  vim.cmd("au CursorMoved,InsertEnter * ++once lua require('dapui.windows').close_float('" .. element.name .. "')")
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
  local closed = float_windows[element_name]:close(false)
  if not closed then
    vim.cmd("au CursorMoved,InsertEnter * ++once lua require('dapui.windows').close_float('" .. element_name .. "')")
  else
    float_windows[element_name] = nil
  end
end

return M
