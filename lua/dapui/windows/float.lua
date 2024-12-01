local M = {}
local api = vim.api
local config = require("dapui.config")

local Float = { win_id = nil, listeners = { close = {} }, position = {} }

local function create_opts(content_width, content_height, position, title)
  local line_no = position.line
  local col_no = position.col

  local vert_anchor = "N"
  local hor_anchor = "W"

  local max_height = config.floating.max_height or vim.o.lines
  local max_width = config.floating.max_width or vim.o.columns
  local border = config.floating.border
  if 0 < max_height and max_height < 1 then
    max_height = math.floor(vim.o.lines * max_height)
  end
  if 0 < max_width and max_width < 1 then
    max_width = math.floor(vim.o.columns * max_width)
  end
  local height = math.min(content_height, max_height - 2)
  local width = math.min(content_width, max_width - 2)

  local row = line_no + math.min(0, vim.o.lines - (height + line_no + 3))
  local col = col_no + math.min(0, vim.o.columns - (width + col_no + 3))

  return {
    relative = "editor",
    row = row,
    col = col,
    anchor = vert_anchor .. hor_anchor,
    width = width,
    height = height,
    style = "minimal",
    border = border,
    title = title,
    title_pos = title and "center",
  }
end

function Float:new(win_id, position)
  local win = {}
  setmetatable(win, self)
  self.__index = self
  win.win_id = win_id
  win.position = position
  return win
end

function Float:listen(event, callback)
  self.listeners[event][#self.listeners[event] + 1] = callback
end

function Float:resize(width, height, position)
  if position == nil then
    position = self.position
  end
  local opts = create_opts(width, height, position)
  api.nvim_win_set_config(self.win_id, opts)
end

function Float:get_buf()
  local pass, win = pcall(api.nvim_win_get_buf, self.win_id)
  if not pass then
    return -1
  end
  return win
end

function Float:jump_to()
  if vim.fn.mode(true) ~= "n" then
    vim.cmd([[call feedkeys("\<C-\>\<C-N>", "n")]])
  end
  api.nvim_set_current_win(self.win_id)
end

function Float:close(force)
  if not force and api.nvim_get_current_win() == self.win_id then
    return false
  end
  local buf = self:get_buf()
  pcall(api.nvim_win_close, self.win_id, true)
  for _, listener in pairs(self.listeners.close) do
    listener({ buffer = buf })
  end
  return true
end

-- settings:
--   Required:
--     height
--     width
--   Optional:
--     buffer
--     position
--     title
function M.open_float(settings)
  local line_no = vim.fn.screenrow()
  local col_no = vim.fn.screencol()
  local position = settings.position or { line = line_no, col = col_no }
  local opts = create_opts(settings.width, settings.height, position, settings.title)
  local content_buffer = settings.buffer or api.nvim_create_buf(false, true)
  local content_window = api.nvim_open_win(content_buffer, false, opts)

  local output_win_id = api.nvim_win_get_number(content_window)
  vim.fn.setwinvar(output_win_id, "&winhl", "Normal:DapUIFloatNormal,FloatBorder:DapUIFloatBorder")
  vim.api.nvim_win_set_option(content_window, "wrap", false)

  return Float:new(content_window, position)
end

return M
