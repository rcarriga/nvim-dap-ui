local M = {}

local async = require("dapui.async")
local api = vim.api
local util = require("dapui.util")
local config = require("dapui.config")
local WindowLayout = require("dapui.windows.layout")

local float_windows = {}

---@type dapui.WindowLayout[]
M.layouts = {}

local function horizontal_layout(height, position, win_configs, buffers)
  local open_cmd = position == "top" and "topleft" or "botright"

  local function open_tray_win(index)
    vim.cmd(index == 1 and open_cmd .. " " .. " split" or "vsplit")
    return buffers[index]
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
  })
end

local function vertical_layout(width, position, win_configs, buffers)
  local open_cmd = position == "left" and "topleft" or "botright"
  local function open_side_win(index)
    vim.cmd(index == 1 and open_cmd .. " " .. "vsplit" or "split")
    return buffers[index]
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
  })
end

function M.area_layout(size, position, win_configs, buffers)
  local win_states = vim.deepcopy(win_configs)
  local layout_func
  if position == "top" or position == "bottom" then
    layout_func = horizontal_layout
  else
    layout_func = vertical_layout
  end
  return layout_func(size, position, win_states, buffers)
end

---@param element_buffers table<string, integer>
function M.setup(element_buffers)
  for _, layout in ipairs(M.layouts) do
    layout:close()
  end
  local layout_configs = config.layouts
  M.layouts = {}
  for i, layout in ipairs(layout_configs) do
    local buffers = {}
    for index, win_config in ipairs(layout.elements) do
      buffers[index] = element_buffers[win_config.id]
    end
    M.layouts[i] = M.area_layout(layout.size, layout.position, layout.elements, buffers)
  end
  if config.force_buffers then
    vim.cmd([[
    augroup DapuiWindowsSetup
      au!
      au BufWinEnter,BufWinLeave * lua require('dapui.windows')._force_buffers()
    augroup END
  ]] )
  end
end

function M._force_buffers()
  for _, layout in ipairs(M.layouts) do
    layout:force_buffers()
  end
end

---@param element dapui.Element
function M.open_float(name, element, position, settings)
  if float_windows[name] then
    float_windows[name]:jump_to()
    return float_windows[name]
  end
  if settings.position == "center" then
    local screen_w = vim.opt.columns:get()
    local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
    position.line = (screen_h - settings.height) / 2;
    position.col = (screen_w - settings.width) / 2;
  end
  local buf = element.buffer()
  local float_win = require("dapui.windows.float").open_float({
    height = settings.height or 1,
    width = settings.width or 1,
    position = position,
    buffer = buf,
  })

  local resize = function()
    local width = settings.width
    local height = settings.height

    if not width or not height then
      local lines = async.api.nvim_buf_get_lines(buf, 0, -1, false)
      if not width then
        width = 0
        for _, line in ipairs(lines) do
          width = math.max(width, vim.str_utfindex(line))
        end
      end

      if not height then
        height = #lines
      end
    end

    if width <= 0 or height <= 0 then
      return
    end
    float_win:resize(width, height)
  end

  async.api.nvim_buf_attach(buf, true, {
    on_lines = function()
      if not vim.api.nvim_win_is_valid(float_win.win_id) then
        return true
      end
      resize()
    end,
  })
  element.render()
  -- In case render doesn't trigger on_lines
  resize()

  util.apply_mapping(config.floating.mappings["close"], "<Cmd>q<CR>", buf)
  local close_cmd = "lua require('dapui.windows').close_float('" .. name .. "')"
  vim.cmd("au WinEnter,CursorMoved * ++once " .. close_cmd)
  vim.cmd("au WinClosed " .. float_win.win_id .. " ++once " .. close_cmd)
  float_windows[name] = float_win
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
  local closed = win:close(false)
  if not closed then
    local close_cmd = "lua require('dapui.windows').close_float('" .. element_name .. "')"
    vim.cmd("au WinEnter * ++once " .. close_cmd)
    vim.cmd("au WinClosed " .. win.win_id .. " ++once " .. close_cmd)
  else
    float_windows[element_name] = nil
  end
end

return M
