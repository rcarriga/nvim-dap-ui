local M = {}

local api = vim.api
local namespace = api.nvim_create_namespace("dapui")

local buf_wins = {}

local function create_buffer(content)
  local buf_nr = api.nvim_create_buf(false, true)
  vim.fn.setbufline(buf_nr, 1, content)
  api.nvim_buf_set_option(buf_nr, "bufhidden", "wipe")
  api.nvim_buf_set_option(buf_nr, "modified", false)

  return buf_nr
end

local function auto_close(win_id, buf_id, orig_line, orig_text)
  if not api.nvim_win_is_valid(win_id) then
    return
  end
  local group = api.nvim_create_augroup("DAPUILongLineExpand" .. buf_id, { clear = true })
  api.nvim_create_autocmd({ "WinEnter", "TabClosed", "CursorMoved" }, {
    callback = function()
      if not api.nvim_win_is_valid(win_id) then
        return
      end
      local cur_line = vim.fn.line(".")
      if
        api.nvim_get_current_buf() == buf_id
        and orig_line == cur_line
        and vim.api.nvim_buf_get_lines(buf_id, cur_line - 1, cur_line, false)[1] == orig_text
      then
        auto_close(win_id, buf_id, orig_line)
        return
      end
      buf_wins[vim.api.nvim_get_current_buf()] = nil
      local ok, error = pcall(api.nvim_win_close, win_id, true)
      if not ok then
        require("dapui.util").notify(error, vim.log.levels.DEBUG)
      end
    end,
    once = true,
    group = group,
  })
end

function M.show()
  local buffer = api.nvim_get_current_buf()
  if api.nvim_win_get_config(0).relative ~= "" then
    return
  end

  local orig_line, orig_col = unpack(api.nvim_win_get_cursor(0))
  orig_line = orig_line - 1

  local line_content = vim.fn.getline("."):sub(orig_col + 1)
  local content_width = vim.str_utfindex(line_content)

  if vim.fn.screencol() + content_width > vim.opt.columns:get() then
    orig_col = 0
    line_content = vim.fn.getline(".")
    content_width = vim.str_utfindex(line_content)
  end

  if
    content_width <= 0
    or content_width
      < vim.fn.winwidth(0) - vim.fn.getwininfo(vim.api.nvim_get_current_win())[1].textoff - orig_col - 1
  then
    return
  end

  if content_width <= 0 then
    return
  end

  local extmarks = api.nvim_buf_get_extmarks(
    buffer,
    namespace,
    { orig_line, 0 },
    { orig_line, -1 },
    { details = true }
  )

  local win_opts = {
    relative = "cursor",
    width = content_width,
    height = 1,
    style = "minimal",
    row = 0,
    col = 0,
  }

  local window_id = buf_wins[buffer]
  local hover_buf
  if window_id and not api.nvim_win_is_valid(window_id) then
    buf_wins[buffer] = nil
    window_id = nil
  end
  -- Use existing window to prevent flickering
  if window_id then
    window_id = buf_wins[buffer]
    hover_buf = api.nvim_win_get_buf(window_id)
    api.nvim_win_set_config(window_id, win_opts)
    api.nvim_buf_set_lines(hover_buf, 0, -1, false, { line_content })
  else
    hover_buf = create_buffer(line_content)
    win_opts.noautocmd = true
    window_id = api.nvim_open_win(hover_buf, false, win_opts)
    buf_wins[buffer] = window_id

    api.nvim_win_call(window_id, function()
      vim.opt.winhighlight:append({ NormalFloat = "Normal" })
    end)
  end

  for _, mark in ipairs(extmarks) do
    local _, _, col, details = unpack(mark)
    if not details.end_col or details.end_col > orig_col then
      details.end_row = 0
      details.ns_id = nil
      details.end_col = details.end_col and (details.end_col - orig_col)
      col = math.max(col, orig_col)
      local ok, error =
        pcall(api.nvim_buf_set_extmark, hover_buf, namespace, 0, col - orig_col, details)
      if not ok then
        require("dapui.util").notify(error, vim.log.levels.DEBUG)
      end
    end
  end

  auto_close(
    window_id,
    buffer,
    orig_line,
    api.nvim_buf_get_lines(buffer, orig_line - 1, orig_line, false)[1]
  )
end

return M
