local M = {}
local api = vim.api

local state = require("dapui.state")
local render = require("dapui.render")

local threads = require("dapui.components.threads")()

local render_receivers = {}

M.name = "DAP Stacks"

local function render_element()
  if vim.tbl_isempty(render_receivers) then return end
  local render_state = render.new()
  threads:render(render_state)
  for buf, reciever in pairs(render_receivers) do
    api.nvim_buf_set_option(buf, "modifiable", true)
    reciever(render_state)
    api.nvim_buf_set_option(buf, "modifiable", false)
  end
end

function M.setup() state.on_refresh(render_element) end

function M.on_open(buf, render_receiver)
  api.nvim_buf_set_option(buf, "filetype", "dapui_stacks")
  api.nvim_buf_set_option(buf, "modifiable", false)
  pcall(api.nvim_buf_set_name, buf, M.name)
  render_receivers[buf] = render_receiver
  render_element()
end

function M.on_close(info) render_receivers[info.buffer] = nil end

return M
