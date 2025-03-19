local config = require("dapui.config")
local Canvas = require("dapui.render.canvas")
local util = require("dapui.util")

---@param client dapui.DAPClient
---@nodoc
return function(client)
  local dapui = { elements = {} }

  ---@class dapui.elements.breakpoints
  ---@toc_entry Breakpoints
  ---@text
  --- Lists all breakpoints currently set.
  ---
  --- Mappings:
  --- - `open`: Jump to the location the breakpoint is set
  --- - `toggle`: Enable/disable the selected breakpoint
  dapui.elements.breakpoints = {
    allow_without_session = true,
  }

  local send_ready = util.create_render_loop(function()
    dapui.elements.breakpoints.render()
  end)

  local breakpoints = require("dapui.components.breakpoints")(client, send_ready)

  ---@nodoc
  function dapui.elements.breakpoints.render()
    local canvas = Canvas.new()
    breakpoints.render(canvas)
    canvas:render_buffer(dapui.elements.breakpoints.buffer(), config.element_mapping("breakpoints"))
  end

  ---@nodoc
  dapui.elements.breakpoints.buffer = util.create_buffer("DAP Breakpoints", {
    filetype = "dapui_breakpoints",
  })

  return dapui.elements.breakpoints
end
