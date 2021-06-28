local M = {}

local state = require("dapui.state")
local render = require("dapui.render")
local api = vim.api
local watches = require("dapui.components.watches")()

local render_receivers = {}

M.name = "DAP Watches"

local render_element = function()
  if vim.tbl_isempty(render_receivers) then return end
  local render_state = render.new()
  watches:render(render_state)
  for _, reciever in pairs(render_receivers) do reciever(render_state) end
end

function M.on_open(buf, render_receiver)
  api.nvim_buf_set_option(buf, "filetype", "dapui_watches")
  api.nvim_buf_set_option(buf, "buftype", "prompt")
  api.nvim_buf_set_option(buf, "omnifunc", "v:lua.require'dap'.omnifunc")
  render_receivers[buf] = render_receiver
  api.nvim_buf_attach(
    buf, false, {
      on_lines = function(b) api.nvim_buf_set_option(b, "modified", false) end,
      on_changedtick = function(b)
        api.nvim_buf_set_option(b, "modified", false)
      end,
    }
  )
  render_element()
end

function M.on_close(info) render_receivers[info.buffer] = nil end

function M.setup() state.on_refresh(render_element) end

return M
