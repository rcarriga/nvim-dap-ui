local M = {}

local state = require("dapui.state")
local config = require("dapui.config")
local render = require("dapui.render")
local util = require("dapui.util")

local variables = require("dapui.components.variables").new()
local scopes = require("dapui.components.scopes").new(variables)

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

function M.toggle_reference()
  local cur_line = vim.fn.line(".")
  local mark_id = render.mark_at_line(cur_line)
  if not mark_id then return end
  variables:toggle_reference(mark_id)
  render_element()
end

function M.on_open(buf, render_receiver)
  vim.api.nvim_buf_set_option(buf, "filetype", "dapui_scopes")
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  pcall(vim.api.nvim_buf_set_name, buf, M.name)
  render_receivers[buf] = render_receiver
  util.apply_mapping(
    config.mappings().expand,
    "<Cmd>lua require('dapui.elements.scopes').toggle_reference()<CR>", buf
  )
  render_element()
end

function M.on_close(info) render_receivers[info.buffer] = nil end

function M.setup() state.on_refresh(render_element) end

return M

