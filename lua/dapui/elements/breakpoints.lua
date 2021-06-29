local M = {}
local listener_id = "dapui_breakpoints"

local breakpoints = require("dapui.components.breakpoints")()

local render_receivers = {}

local function render_breakpoints()
  local render_state = require("dapui.render").new()
  breakpoints:render(render_state)
  for buf, reciever in pairs(render_receivers) do
    vim.api.nvim_buf_set_option(buf, "modifiable", true)
    reciever(render_state)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
  end
end

M.name = "DAP Breakpoints"

function M.on_open(buf, render_receiver)
  vim.api.nvim_buf_set_option(buf, "filetype", "dapui_breakpoints")
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  pcall(vim.api.nvim_buf_set_name, buf, M.name)
  render_receivers[buf] = render_receiver
  render_breakpoints()
end

function M.on_close(info) render_receivers[info.buffer] = nil end

function M.setup()

  local dap = require("dap")
  dap.listeners.after.setBreakpoints[listener_id] = render_breakpoints
  dap.listeners.after.setFunctionBreakpoints[listener_id] = render_breakpoints
  dap.listeners.after.setInstructionBreakpoints[listener_id] =
    render_breakpoints
  dap.listeners.after.setDataBreakpoints[listener_id] = render_breakpoints
  dap.listeners.after.stackTrace[listener_id] = render_breakpoints
end

return M
