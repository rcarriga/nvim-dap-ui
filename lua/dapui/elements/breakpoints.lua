local config = require("dapui.config")
local Canvas = require("dapui.render.canvas")
local lib = require("dapui.lib")

---@param client dapui.DAPClient
return function(client)
  local dapui = { breakpoints = {} }
  local send_ready = lib.create_render_loop(function()
    dapui.breakpoints.render()
  end)

  local breakpoints = require("dapui.components.breakpoints")(client, send_ready)

  local buf = lib.create_buffer("DAP Breakpoints", {
    filetype = "dapui_breakpoints",
  })

  function dapui.breakpoints.render()
    local canvas = Canvas.new()
    breakpoints.render(canvas)
    canvas:render_buffer(buf, config.element_mapping("breakpoints"))
  end

  function dapui.breakpoints.buffer()
    return buf
  end

  return dapui.breakpoints
end
