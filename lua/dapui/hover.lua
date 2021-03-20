local M = {}
local listener_id = "dapui_hover"
local Hover = {
  eval = {win = nil},
  stack_frames = {}
}

vim.cmd("hi default DapUIHoverBorder guifg=#00F1F5")

local function open_hover(contents, filetype)
  local line_no = vim.fn.screenrow()
  local col_no = vim.fn.screencol()

  local vert_anchor = "N"
  local hor_anchor = "W"

  local height = #contents + 2
  local width = 0

  local row = vim.fn.min({1, vim.fn.eval("&lines") - (line_no + height)})
  local col = vim.fn.min({1, vim.fn.eval("&columns") - (col_no + width)})

  for _, line in pairs(contents) do
    width = width < #line and #line or width
  end
  width = width + 4

  local border_opts = {
    relative = "cursor",
    row = row,
    col = col,
    anchor = vert_anchor .. hor_anchor,
    width = width,
    height = height,
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
  vim.api.nvim_buf_set_lines(content_buffer, 0, -1, true, contents)
  local border_buffer = vim.api.nvim_create_buf(false, true)
  local content_window = vim.api.nvim_open_win(content_buffer, false, content_opts)
  local output_win_id = vim.api.nvim_win_get_number(content_window)
  vim.fn.setbufvar(content_buffer, "&filetype", filetype)
  vim.fn.setwinvar(output_win_id, "&winhl", "Normal:Normal")
  local border_lines = {"╭" .. string.rep("─", border_opts.width - 2) .. "╮"}
  for _, line in pairs(contents) do
    border_lines[#border_lines + 1] = "│" .. string.rep(" ", border_opts.width - 2) .. "│"
  end
  border_lines[#border_lines + 1] = "╰" .. string.rep("─", border_opts.width - 2) .. "╯"

  vim.api.nvim_buf_set_lines(border_buffer, 0, -1, true, border_lines)
  local border_window = vim.api.nvim_open_win(border_buffer, false, border_opts)
  local border_win_id = vim.api.nvim_win_get_number(border_window)
  vim.fn.setwinvar(border_window, "&winhl", "Normal:Normal")
  vim.fn.matchadd("DapUIHoverBorder", ".*", 100, -1, {window = border_window})

  return {content_window, border_window}
end

function M.close(wins, force)
  if not force and vim.api.nvim_get_current_win() == wins[1] then
    vim.cmd("au CursorMoved * ++once lua require('dapui.hover').close(" .. vim.inspect(wins) .. ", false)")
    return
  end
  for _, win in pairs(wins) do
    local buf = vim.api.nvim_win_get_buf(win)
    vim.api.nvim_win_close(win, true)
  end
  Hover.eval.win = nil
end

function M.eval_cursor()
  if Hover.eval.win ~= nil then
    vim.api.nvim_set_current_win(Hover.eval.win)
    return
  end
  local dap = require("dap")
  local session = dap.session()
  if not session then
    print("No active session to query")
    return
  end
  local expr = vim.fn.expand("<cexpr>")
  local filetype = (vim.fn.getbufvar(vim.fn.expand("%"), "&filetype"))
  session:request(
    "evaluate",
    {
      expression = expr,
      frameId = session.current_frame.id,
      context = "hover"
    },
    function(_, response)
      if not response then
        print("Couldn't evaluate expression " .. expr .. " in current frame.")
        return
      end
      local hover_wins = open_hover({response.result}, filetype)
      Hover.eval.win = hover_wins[1]
      vim.cmd("au CursorMoved * ++once lua require('dapui.hover').close(" .. vim.inspect(hover_wins) .. ", false)")
    end
  )
end

function M.setup(user_config)
  local dap = require("dap")

  dap.listeners.stackTrace[listener_id] = function(session, err, response)
    if not err then
      Hover.stack_frames = response.stackFrames
    end
  end
end

return M
