local M = {}

local api = vim.api
local default_debounce_time = 300
local window_id = nil

local timer = vim.loop.new_timer()

function M.show_delayed(debounce_time)
  timer:start(debounce_time or default_debounce_time, 0, vim.schedule_wrap(function()
    M.show()
  end))
end

local function create_buffer(content)
  local buf_nr = api.nvim_create_buf(false, false)
  vim.fn.setbufline(buf_nr, 1, content)
  api.nvim_buf_set_option(buf_nr, "bufhidden", "wipe")
  api.nvim_buf_set_option(buf_nr, "buftype", "nofile")
  api.nvim_buf_set_option(buf_nr, "modified", false)

  return buf_nr
end

function M.hide_existing_window()
  timer:stop()

  if nil == window_id or not api.nvim_win_is_valid(window_id) then
    return
  end

  api.nvim_win_close(window_id, true)
end

function M.show()
  M.hide_existing_window()
  local line_content = vim.fn.getline("."):gsub("[^%g* ]+$", "")
  local content_width = vim.fn.strdisplaywidth(line_content) + 1

  if content_width < vim.fn.winwidth(0) then
    return
  end

  local buf_nr = create_buffer(line_content)

  window_id = api.nvim_open_win(buf_nr, false, {
    relative = "win",
    width = content_width,
    height = 1,
    noautocmd = true,
    style = "minimal",
    bufpos = { vim.fn.line(".") - 2, 0 },
  })

  api.nvim_win_set_option(window_id, "winhighlight", "NormalFloat:Normal")
end

function M.enable_for_window()
  vim.notify(api.nvim_buf_get_name(0))
  if vim.fn.has("nvim-0.7") == 1 then
    api.nvim_create_augroup("ArctgxLineHover", { clear = true })
    api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      group = "ArctgxLineHover",
      buffer = 0,
      -- buffer = bufnr,
      callback = M.show_delayed,
    })
    api.nvim_create_autocmd({ "BufLeave", "TabClosed" }, {
      group = "ArctgxLineHover",
      buffer = 0,
      -- buffer = bufnr,
      callback = M.hide_existing_window,
    })
  end
end

return M
