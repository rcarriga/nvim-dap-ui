local M = {}

local nio = require("nio")
local api = vim.api
local util = require("dapui.util")
local config = require("dapui.config")
local WindowLayout = require("dapui.windows.layout")

local float_windows = {}

---@type dapui.WindowLayout[]
M.layouts = {}

local registered_elements = {}

local function horizontal_layout(height, position, win_configs, buffers)
  local open_cmd = position == "top" and "topleft" or "botright"

  local function open_tray_win(index)
    vim.cmd(index == 1 and open_cmd .. " " .. " split" or "vsplit")
    return buffers[index]
  end

  local win_states = {}
  for _, conf in ipairs(win_configs) do
    win_states[#win_states + 1] = vim.tbl_extend("force", conf, { init_size = conf.size })
  end

  return WindowLayout({
    layout_type = "horizontal",
    area_state = { size = height, init_size = height },
    win_states = win_states,
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

  local win_states = {}
  for _, conf in ipairs(win_configs) do
    win_states[#win_states + 1] = vim.tbl_extend("force", conf, { init_size = conf.size })
  end

  return WindowLayout({
    layout_type = "vertical",
    area_state = { size = width, init_size = width },
    win_states = win_states,
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

local function force_buffers(keep_current)
  for _, layout in ipairs(M.layouts) do
    layout:force_buffers(keep_current)
  end
end

---@param element_buffers table<string, integer>
function M.setup(element_buffers)
  local dummy_buf = util.create_buffer("", {})
  for _, layout in ipairs(M.layouts) do
    layout:close()
  end
  local layout_configs = config.layouts
  M.layouts = {}
  for i, layout in ipairs(layout_configs) do
    local buffers = {}
    for index, win_config in ipairs(layout.elements) do
      buffers[index] = element_buffers[win_config.id]
        or function()
          local elem = registered_elements[win_config.id]
          if not elem then
            return dummy_buf()
          end
          return elem.buffer()
        end
    end
    M.layouts[i] = M.area_layout(layout.size, layout.position, layout.elements, buffers)
  end
  if config.force_buffers then
    local group = api.nvim_create_augroup("DapuiWindowsSetup", {})
    api.nvim_create_autocmd({ "BufWinEnter", "BufWinLeave" }, {
      callback = function()
        force_buffers(false)
      end,
      group = group,
    })
  end
end

function M.register_element(name, elem)
  registered_elements[name] = elem
  force_buffers(false)
end

---@param element dapui.Element
function M.open_float(name, element, position, settings)
  if float_windows[name] then
    float_windows[name]:jump_to()
    return float_windows[name]
  end
  local buf = element.buffer()
  local float_win = require("dapui.windows.float").open_float({
    height = settings.height or 1,
    width = settings.width or 1,
    position = position,
    buffer = buf,
    title = settings.title,
  })

  local resize = function()
    local width = settings.width
    local height = settings.height

    if not width or not height then
      local lines = nio.api.nvim_buf_get_lines(buf, 0, -1, false)
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

    if settings.position == "center" then
      local screen_w = vim.opt.columns:get()
      local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
      position.line = (screen_h - height) / 2
      position.col = (screen_w - width) / 2
    end

    if width <= 0 or height <= 0 then
      return
    end
    float_win:resize(width, height, position)
  end

  nio.api.nvim_buf_attach(buf, true, {
    on_lines = function()
      if not vim.api.nvim_win_is_valid(float_win.win_id) then
        return true
      end
      resize()
    end,
  })
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
