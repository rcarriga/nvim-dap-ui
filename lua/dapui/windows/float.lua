local M = {}
local api = vim.api

vim.cmd("hi default DapUIFloatBorder guifg=#00F1F5")

local Float = {ids = {}, listeners = {close = {}}, position = {}}

local function create_border_lines(border_opts)
  local width = border_opts.width
  local height = border_opts.height
  local border_lines = {"╭" .. string.rep("─", width - 2) .. "╮"}
  for _ = 3, height, 1 do
    border_lines[#border_lines + 1] = "│" .. string.rep(" ", width - 2) .. "│"
  end
  border_lines[#border_lines + 1] = "╰" .. string.rep("─", width - 2) .. "╯"
  return border_lines
end

local function create_border_opts(content_width, content_height, position)
  local line_no = position.line
  local col_no = position.col

  local vert_anchor = "N"
  local hor_anchor = "W"

  local height = math.min(content_height + 2, vim.o.lines - 2)
  local width = math.min(content_width + 4, vim.o.columns - 2)

  local row = line_no + math.min(0, vim.o.lines - (height + line_no + 2))
  local col = col_no + math.min(0, vim.o.columns - (width + col_no + 2))

  return {
    relative = "editor",
    row = row,
    col = col,
    anchor = vert_anchor .. hor_anchor,
    width = width,
    height = height,
    style = "minimal"
  }
end

local function create_content_opts(border_opts)
  return vim.tbl_extend(
    "keep",
    {
      row = border_opts.row + 1,
      height = border_opts.height - 2,
      col = border_opts.col + 2,
      width = border_opts.width - 4
    },
    border_opts
  )
end

function Float:new(ids, position)
  local win = {}
  setmetatable(win, self)
  self.__index = self
  win.ids = ids
  win.position = position
  return win
end

function Float:listen(event, callback)
  self.listeners[event][#self.listeners[event] + 1] = callback
end

function Float:resize(width, height)
  local border_opts = create_border_opts(width, height, self.position)
  local content_opts = create_content_opts(border_opts)

  api.nvim_win_set_config(self.ids[1], content_opts)
  api.nvim_win_set_config(self.ids[2], border_opts)

  local border_buffer = api.nvim_win_get_buf(self.ids[2])
  api.nvim_buf_set_lines(border_buffer, 0, -1, true, create_border_lines(border_opts))
end

function Float:get_buf()
  local pass, win = pcall(api.nvim_win_get_buf, self.ids[1])
  if not pass then
    return -1
  end
  return win
end

function Float:jump_to()
  api.nvim_set_current_win(self.ids[1])
end

function Float:close(force)
  if not force and api.nvim_get_current_win() == self.ids[1] then
    return false
  end
  local buf = self:get_buf()
  for _, win_id in pairs(self.ids) do
    api.nvim_win_close(win_id, true)
  end
  for _, listener in pairs(self.listeners.close) do
    listener({buffer = buf})
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
function M.open_float(settings)
  local line_no = vim.fn.screenrow()
  local col_no = vim.fn.screencol()
  local position = settings.position or {line = line_no, col = col_no}

  local border_opts = create_border_opts(settings.width, settings.height, position)
  local content_opts = create_content_opts(border_opts)

  local content_buffer = settings.buffer or api.nvim_create_buf(false, true)
  local border_buffer = api.nvim_create_buf(false, true)

  local content_window = api.nvim_open_win(content_buffer, false, content_opts)

  local output_win_id = api.nvim_win_get_number(content_window)
  vim.fn.setwinvar(output_win_id, "&winhl", "Normal:Normal")

  local border_lines = create_border_lines(border_opts)

  api.nvim_buf_set_lines(border_buffer, 0, -1, true, border_lines)
  local border_window = api.nvim_open_win(border_buffer, false, border_opts)
  vim.fn.setwinvar(border_window, "&winhl", "Normal:Normal")
  vim.fn.matchadd("DapUIFloatBorder", ".*", 100, -1, {window = border_window})

  return Float:new({content_window, border_window}, position)
end

return M
