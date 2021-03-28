local M = {}
local api = vim.api
local listener_id = "dapui_stack"

M.buffer_info = {
  name = "DAP Stacks",
  settings = {
    filetype = "dapui_stacks"
  },
  on_open = function()
    local buf_num = vim.fn.bufnr(M.buffer_info.name)
    api.nvim_buf_set_keymap(buf_num, "n", "<CR>", "<Cmd>lua require('dapui.stacks').jump_to_frame()<CR>", {})
  end
}

local StackTrace = {
  threads = {},
  thread_frames = {},
  current_frame_id = nil,
  line_frame_map = {}
}

function StackTrace:render_frames(frames, render_state, indent)
  for _, frame in pairs(frames or {}) do
    local line_no = render_state:length() + 1
    self.line_frame_map[line_no] = frame

    local new_line = string.rep(" ", indent)

    render_state:add_match("DapUIFrameName", line_no, #new_line + 1, #frame.name)
    new_line = new_line .. frame.name .. " ("

    local source_name = vim.fn.fnamemodify(frame.source.path, ":.")
    if vim.startswith(source_name, ".") then
      source_name = frame.source.path
    end
    render_state:add_match("DapUIFrameSource", line_no, #new_line + 1, #source_name)
    new_line = new_line .. source_name .. ":"

    render_state:add_match("DapUILineNumber", line_no, #new_line + 1, #tostring(frame.line))
    new_line = new_line .. frame.line .. ")"

    render_state:add_line(new_line)
  end
end

function StackTrace:render_threads(match_group, threads, render_state)
  local ordered_keys = {}

  for k in pairs(threads) do
    table.insert(ordered_keys, k)
  end
  table.sort(ordered_keys)

  for i = 1, #ordered_keys do
    local thread = threads[ordered_keys[i]]
    render_state:add_match(match_group, render_state:length() + 1, 1, #thread.name)
    render_state:add_line(thread.name .. ":")
    self:render_frames(self.thread_frames[thread.id], render_state, 1)
    if i < #ordered_keys then
      render_state:add_line()
    end
    i = i + 1
  end
end

function StackTrace:fill_render_state(render_state, stopped_thread)
  if not self.threads then
    return
  end
  local secondary_threads = {}
  for k, thread in pairs(self.threads) do
    if thread.id ~= stopped_thread then
      secondary_threads[k] = thread
    end
  end
  self:render_threads("DapUIStoppedThread", {self.threads[stopped_thread]}, render_state)
  render_state:add_line()
  self:render_threads("DapUIThread", secondary_threads, render_state)
end

function StackTrace:refresh()
  local session = require("dap").session()
  if not session or not session.current_frame then
    return
  end
  self.current_frame_id = session.current_frame.id
  local win = vim.fn["bufwinnr"](M.buffer_info.name)
  if win >= 0 then
    local render_state = require("dapui.render").init_state()
    self:fill_render_state(render_state, session.stopped_thread_id)
    render_state:render_buffer(win, M.buffer_info.name)
  end
end

function M.jump_to_frame()
  local current_frame = StackTrace.line_frame_map[vim.fn["getbufinfo"](M.buffer_info.name)[1].lnum]
  if not current_frame then
    return
  end
  local source = current_frame.source
  local line = current_frame.line
  local column = current_frame.column
  if not column or column == 0 then
    column = 1
  end

  local scheme = source.path:match("^([a-z]+)://.*")
  local bufnr
  if scheme then
    bufnr = vim.uri_to_bufnr(source.path)
  else
    bufnr = vim.uri_to_bufnr(vim.uri_from_fname(source.path))
  end

  vim.fn.bufload(bufnr)

  for _, win in pairs(api.nvim_tabpage_list_wins(0)) do
    if api.nvim_win_get_buf(win) == bufnr then
      api.nvim_win_set_cursor(win, {line, column - 1})
      api.nvim_set_current_win(win)
      return
    end
  end

  for _, win in pairs(api.nvim_tabpage_list_wins(0)) do
    local winbuf = api.nvim_win_get_buf(win)
    if api.nvim_buf_get_option(winbuf, "buftype") == "" then
      local bufchanged, _ = pcall(api.nvim_win_set_buf, win, bufnr)
      if bufchanged then
        api.nvim_win_set_cursor(win, {line, column - 1})
        api.nvim_set_current_win(win)
        return
      end
    end
  end
end

function M.setup()
  vim.cmd("hi default DapUIThread guifg=#A9FF68")
  vim.cmd("hi default DapUIStoppedThread guifg=#F70067 gui=bold")
  vim.cmd("hi default link DapUIFrameName Normal")
  vim.cmd("hi default DapUIFrameSource guifg=#D484FF")
  vim.cmd("hi default DapUILineNumber guifg=#00f1f5")
  local dap = require("dap")
  dap.listeners.after.threads[listener_id] = function(session, err, response, request)
    if err then
      return
    end
    for _, thread in pairs(response.threads) do
      StackTrace.threads[thread.id] = thread
      if not StackTrace.thread_frames[thread.id] then
        session:request(
          "stackTrace",
          {threadId = thread.id},
          function()
          end
        )
      end
    end
    StackTrace:refresh()
  end
  dap.listeners.after.stackTrace[listener_id] = function(session, err, response, request)
    if err then
      return
    end
    StackTrace.thread_frames[request.threadId] = response.stackFrames
    StackTrace:refresh()
  end
  dap.listeners.after.event_stopped[listener_id] = function(session, body)
    session:request(
      "threads",
      {},
      function()
      end
    )
  end
end

return M
