local config = require("dapui.config")
local util = require("dapui.util")
local Canvas = require("dapui.render.canvas")

return function(client)
  local dapui = { scopes = {} }
  local send_ready = util.create_render_loop(function()
    dapui.scopes.render()
  end)

  local scopes = require("dapui.components.scopes")(client, send_ready)

  local buf = util.create_buffer("DAP Scopes", {
    filetype = "dapui_scopes",
  })

  function dapui.scopes.render()
    local canvas = Canvas.new()
    scopes.render(canvas)
    canvas:render_buffer(buf, config.element_mapping("scopes"))
  end

  function dapui.scopes.buffer()
    return buf
  end

  return dapui.scopes
end
