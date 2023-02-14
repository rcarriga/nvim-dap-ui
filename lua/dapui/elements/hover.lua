local config = require("dapui.config")
local util = require("dapui.util")
local Canvas = require("dapui.render.canvas")

return function(client)
  local dapui = { elements = {} }

  ---@class dapui.elements.hover
  dapui.elements.hover = {}

  local send_ready = util.create_render_loop(function()
    dapui.elements.hover.render()
  end)

  local hover = require("dapui.components.hover")(client, send_ready)

  ---@nodoc
  function dapui.elements.hover.render()
    local canvas = Canvas.new()
    hover.render(canvas)
    canvas:render_buffer(dapui.elements.hover.buffer(), config.element_mapping("hover"))
  end

  ---@nodoc
  dapui.elements.hover.buffer = util.create_buffer("DAP Hover", {
    filetype = "dapui_hover",
  })

  ---Set the expression for the hover window
  ---@param expression string
  function dapui.elements.hover.set_expression(expression, context)
    hover.set_expression(expression, context)
  end

  return dapui.elements.hover
end
