local config = require("dapui.config")
local lib = require("dapui.lib")
local Canvas = require("dapui.render.canvas")

return function(client)
  local dapui = { hover = {} }
  local buf = lib.create_buffer("DAP Hover", {
    filetype = "dapui_hover",
  })

  local send_ready = lib.create_render_loop(function()
    dapui.hover.render()
  end)

  local hover = require("dapui.components.hover")(client, send_ready)

  function dapui.hover.render()
    local canvas = Canvas.new()
    hover.render(canvas)
    canvas:render_buffer(buf, config.element_mapping("hover"))
  end

  function dapui.hover.buffer()
    return buf
  end

  ---Set the expression for the hover window
  ---@param expression string
  function dapui.hover.set_expression(expression, context)
    hover.set_expression(expression, context)
  end

  return dapui.hover
end
