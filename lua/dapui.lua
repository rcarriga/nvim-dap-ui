local M = {}

local listener_id = "dapui"

local function fill_config(config)
  return vim.tbl_deep_extend(
    "keep",
    config,
    {
      use_icons = false,
      collapsed_icon = nil,
      expanded_icon = nil,
      circular_ref_icon = nil,
      scopes = true,
      stacks = true
    }
  )
end

function M.setup(config)
  config = fill_config(config or {})
  local buffers_info = {}
  if config.scopes then
    local vars = require("dapui.scopes")
    buffers_info[#buffers_info + 1] = vars.buffer_info
    vars.setup(config)
  end
  if config.stacks then
    local stacks = require("dapui.stacks")
    buffers_info[#buffers_info + 1] = stacks.buffer_info
    stacks.setup(config)
  end
  local dap = require("dap")
  dap.listeners.before.event_initialized[listener_id] = function()
    require("dapui.base").open(buffers_info)
  end

  dap.listeners.before.event_terminated[listener_id] = function()
    require("dapui.base").close(buffers_info)
  end

  dap.listeners.before.event_exited[listener_id] = function()
    require("dapui.base").close(buffers_info)
  end
end

return M
