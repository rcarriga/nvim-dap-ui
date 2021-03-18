local M = {}
local listener_id = "dapui_stack"

M.buffer_info = {
  name = "DAP Frames",
  settings = {
    filetype = "dapui_stack"
  },
  on_open = function()
  end
}

local StackTrace = {
  threads = {},
  line_frame_map = {}
}

vim.cmd("hi default DapUIThread guifg=#A9FF68")
vim.cmd("hi default link DapUIFrameName Normal")
vim.cmd("hi default DapUIFrameSource guifg=#D484FF")
vim.cmd("hi default DapUIColumnNumber guifg=#F79000")
vim.cmd("hi default DapUILineNumber guifg=#00f1f5")

function StackTrace:update_state(session)
  self.threads = session.threads
end

function StackTrace:render_frames(frames, render_state, indent)
  for _, frame in pairs(frames or {}) do
    self.line_frame_map[#render_state.lines + 1] = frame.id

    local new_line = string.rep(" ", indent)

    render_state.matches[#render_state.matches + 1] = {
      "DapUIFrameName",
      {#render_state.lines + 1, #new_line + 1, #frame.name}
    }
    new_line = new_line .. frame.name .. " ("

    local source_name = vim.fn.fnamemodify(frame.source.path, ":.")
    if vim.startswith(source_name, ".") then
      source_name = frame.source.path
    end
    render_state.matches[#render_state.matches + 1] = {
      "DapUIFrameSource",
      {#render_state.lines + 1, #new_line + 1, #source_name}
    }
    new_line = new_line .. source_name .. " "

    render_state.matches[#render_state.matches + 1] = {
      "DapUILineNumber",
      {#render_state.lines + 1, #new_line + 1, #tostring(frame.line)}
    }
    new_line = new_line .. frame.line .. ":"

    render_state.matches[#render_state.matches + 1] = {
      "DapUIColumnNumber",
      {#render_state.lines + 1, #new_line + 1, #tostring(frame.column)}
    }
    new_line = new_line .. frame.column .. ")"

    render_state.lines[#render_state.lines + 1] = new_line
  end
  return render_state
end

function StackTrace:render(win)
  local render_state = {
    lines = {},
    matches = {}
  }
  for i, thread in pairs(self.threads or {}) do
    render_state.matches[#render_state.matches + 1] = {"DapUIThread", {#render_state.lines + 1, 1, #thread.name}}
    render_state.lines[#render_state.lines + 1] = thread.name .. ":"
    render_state = self:render_frames(thread.frames, render_state, 1)
    if i < #self.threads then
      render_state.lines[#render_state.lines + 1] = ""
    end
  end
  vim.fn["setbufvar"](M.buffer_info.name, "&modifiable", 1)
  vim.fn["clearmatches"](win)
  vim.api.nvim_buf_set_lines(vim.fn["bufnr"](M.buffer_info.name), 0, #render_state.lines, false, render_state.lines)
  local last_line = vim.fn["line"]("$")
  if last_line > #render_state.lines then
    vim.api.nvim_buf_set_lines(vim.fn["bufnr"](M.buffer_info.name), #render_state.lines, last_line, false, {})
  end
  for _, match in pairs(render_state.matches) do
    vim.fn["matchaddpos"](match[1], {match[2]}, 10, -1, {window = win})
  end
  vim.fn["setbufvar"](M.buffer_info.name, "&modifiable", 0)
end

function StackTrace:refresh()
  local session = require("dap").session()
  if not session or not session.current_frame then
    return
  end
  self:update_state(session)
  local win = vim.fn["bufwinnr"](M.buffer_info.name)
  if win >= 0 then
    self:render(win)
  end
end

function M.setup()
  local dap = require("dap")
  dap.listeners.after.stackTrace[listener_id] = function(session, err, response, request)
    StackTrace:refresh()
  end

  dap.listeners.after.event_stopped[listener_id] = function()
  end
end

return M
