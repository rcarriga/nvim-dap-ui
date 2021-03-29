local M = {}

vim.cmd("hi default DapUIFloatBorder guifg=#00F1F5")

local Float = {ids = {}}

local function create_border_lines(width, height)
  local border_lines = {"╭" .. string.rep("─", width - 2) .. "╮"}
  for _ = 3, height, 1 do
    border_lines[#border_lines + 1] = "│" .. string.rep(" ", width - 2) .. "│"
  end
  border_lines[#border_lines + 1] = "╰" .. string.rep("─", width - 2) .. "╯"
  return border_lines
end

function Float:new(ids)
  local win = {}
  setmetatable(win, self)
  self.__index = self
  win.ids = ids

  return win
end

function Float:resize(width, height)
  vim.api.nvim_win_set_width(self.ids[1], width)
  vim.api.nvim_win_set_width(self.ids[2], width + 4)
  vim.api.nvim_win_set_height(self.ids[1], height)
  vim.api.nvim_win_set_height(self.ids[2], height + 2)
  local border_buffer = vim.api.nvim_win_get_buf(self.ids[2])
  vim.api.nvim_buf_set_lines(border_buffer, 0, -1, true, create_border_lines(width + 4, height + 2))
end

function Float:get_buf()
  local pass, win = pcall(vim.api.nvim_win_get_buf, self.ids[1])
  if not pass then
    return -1
  end
  return win
end

function Float:jump_to()
  vim.api.nvim_set_current_win(self.ids[1])
end

function Float:close(force)
  if not force and vim.api.nvim_get_current_win() == self.ids[1] then
    return false
  end
  for _, win_id in pairs(self.ids) do
    vim.api.nvim_win_close(win_id, true)
  end
  return true
end

-- settings:
--   Required:
--     height
--     width
--   Optional:
--     filetype
function M.open_float(settings)
  local line_no = vim.fn.screenrow()
  local col_no = vim.fn.screencol()

  local vert_anchor = "N"
  local hor_anchor = "W"

  local height = settings.height
  local width = settings.width

  local row = vim.fn.min({1, vim.fn.eval("&lines") - (line_no + height)})
  local col = vim.fn.min({1, vim.fn.eval("&columns") - (col_no + width)})

  local border_opts = {
    relative = "cursor",
    row = row,
    col = col,
    anchor = vert_anchor .. hor_anchor,
    width = width + 4,
    height = height + 2,
    style = "minimal"
  }

  local content_opts =
    vim.tbl_extend(
    "keep",
    {
      row = border_opts.row + 1,
      height = border_opts.height - 2,
      col = border_opts.col + 2,
      width = border_opts.width - 4
    },
    border_opts
  )

  local content_buffer = vim.api.nvim_create_buf(false, true)
  local border_buffer = vim.api.nvim_create_buf(false, true)

  local content_window = vim.api.nvim_open_win(content_buffer, false, content_opts)

  if settings.filetype then
    vim.fn.setbufvar(content_buffer, "&filetype", settings.filetype)
  end

  local output_win_id = vim.api.nvim_win_get_number(content_window)
  vim.fn.setwinvar(output_win_id, "&winhl", "Normal:Normal")

  local border_lines = create_border_lines(border_opts.width, border_opts.height)

  vim.api.nvim_buf_set_lines(border_buffer, 0, -1, true, border_lines)
  local border_window = vim.api.nvim_open_win(border_buffer, false, border_opts)
  vim.fn.setwinvar(border_window, "&winhl", "Normal:Normal")
  vim.fn.matchadd("DapUIFloatBorder", ".*", 100, -1, {window = border_window})

  return Float:new({content_window, border_window})
end

return M
