local M = {}

local state = require("dapui.state")
local render = require("dapui.render")

local scopes = require("dapui.components.scopes")()

local render_receivers = {}

M.name = "DAP Scopes"

local render_element = function()
  if vim.tbl_isempty(render_receivers) then return end
  local render_state = render.new()
  scopes:render(render_state)
  for buf, reciever in pairs(render_receivers) do
    vim.api.nvim_buf_set_option(buf, "modifiable", true)
    reciever(render_state)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
  end
end

function M.on_open(buf, render_receiver)
  vim.api.nvim_buf_set_option(buf, "filetype", "dapui_scopes")
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  pcall(vim.api.nvim_buf_set_name, buf, M.name)
  render_receivers[buf] = render_receiver
  render_element()
end

function M.on_close(info) render_receivers[info.buffer] = nil end

function M.setup() state.on_refresh(render_element) end

return M

