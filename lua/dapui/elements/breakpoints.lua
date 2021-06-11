local M = {}

local Element = {}

local function reset_state()
  Element.render_receiver = {}
  Element.breakpoints = {}
  Element.line_breakpoint_map = {}
  Element.expanded_breakpoints = {}
end

reset_state()

function Element:render_breakpoints(buffer, breakpoints, render_state, is_current_line)
  local indent = self.config.windows.indent
  for _, bp in pairs(breakpoints) do
    local line_no = render_state:length() + 1
    self.line_breakpoint_map[line_no] = bp

    local text = vim.api.nvim_buf_get_lines(buffer, bp.line - 1, bp.line, false)

    local new_line = string.rep(" ", indent) .. bp.line
    render_state:add_match(
      is_current_line(bp) and "DapUIBreakpointsCurrentLine" or "DapUIBreakpointsLine",
      line_no,
      indent + 1,
      #tostring(bp.line)
    )

    new_line = new_line .. " " .. vim.trim(text[1])
    render_state:add_line(new_line)

    local info_indent = indent + #tostring(bp.line) + 1
    local whitespace = string.rep(" ", info_indent)

    local function add_info(message, data)
      local log_line = whitespace .. message .. " " .. data
      render_state:add_line(log_line)
      render_state:add_match("DapUIBreakpointsInfo", render_state:length(), info_indent, #message)
      self.line_breakpoint_map[render_state:length()] = bp
    end
    if bp.logMessage then
      add_info("Log Message:", bp.logMessage)
    end
    if bp.condition then
      add_info("Condition:", bp.condition)
    end
    if bp.hitCondition then
      add_info("Hit Condition:", bp.hitCondition)
    end
  end
end

function Element:should_render(session)
  return session and not vim.tbl_isempty(self.render_receiver)
end

function Element:render(session)
  if not self:should_render(session) then
    return
  end
  local current_frame = session.current_frame
  local current_file = ""
  local current_line = -1
  if current_frame and current_frame.source then
    current_file = require("dapui.util").pretty_name(current_frame.source.path)
    current_line = current_frame.line
  end
  local function is_current_line(bp)
    return bp.line == current_line and bp.file == current_file
  end

  local render_state = require("dapui.render").init_state()
  for buffer, breakpoints in pairs(self.breakpoints or {}) do
    local name = require("dapui.util").pretty_name(vim.fn.bufname(buffer))
    render_state:add_match("DapUIBreakpointsPath", render_state:length() + 1, 1, #name)
    render_state:add_line(name .. ":")
    self:render_breakpoints(buffer, breakpoints, render_state, is_current_line)
    render_state:add_line()
  end
  render_state:remove_line()
  for buf, reciever in pairs(self.render_receiver) do
    vim.api.nvim_buf_set_option(buf, "modifiable", true)
    reciever(render_state)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
  end
end

function Element:refresh_breakpoints(session)
  local breakpoints = require("dap.breakpoints").get()
  for buffer, buf_points in pairs(breakpoints) do
    if not vim.tbl_isempty(buf_points) then
      local buf_name = vim.fn.bufname(buffer)
      for _, bp in pairs(buf_points) do
        bp.file = buf_name
      end
      self.breakpoints[buffer] = buf_points
    end
  end
  self:render(session)
end

local listener_id = "dapui_breakpoints"

M.name = "DAP Breakpoints"

function M.open_breakpoint()
  local line = vim.fn.line(".")
  local current_bp = Element.line_breakpoint_map[line]
  if not current_bp then
    return
  end
  require("dapui.util").jump_to_frame({line = current_bp.line, column = 0, source = {path = current_bp.file}})
end

function M.on_open(buf, render_receiver)
  vim.api.nvim_buf_set_option(buf, "filetype", "dapui_breakpoints")
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  pcall(vim.api.nvim_buf_set_name, buf, M.name)
  Element.render_receiver[buf] = render_receiver
  require("dapui.util").apply_mapping(
    Element.config.mappings.open,
    "<Cmd>lua require('dapui.elements.breakpoints').open_breakpoint()<CR>",
    buf
  )
  local session = require("dap").session()
  Element:refresh_breakpoints(session)
end

function M.on_close(info)
  Element.render_receiver[info.buffer] = nil
end

function M.setup(user_config)
  Element.config = user_config

  local dap = require("dap")
  local refresh = function(session)
    Element:refresh_breakpoints(session)
  end
  dap.listeners.after.setBreakpoints[listener_id] = refresh
  dap.listeners.after.setFunctionBreakpoints[listener_id] = refresh
  dap.listeners.after.setInstructionBreakpoints[listener_id] = refresh
  dap.listeners.after.setDataBreakpoints[listener_id] = refresh
  dap.listeners.after.stackTrace[listener_id] = refresh

  dap.listeners.after.event_terminated[listener_id] = function()
    reset_state()
  end
end

return M
