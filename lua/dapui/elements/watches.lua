local lib = require("dapui.lib")
local config = require("dapui.config")
local Canvas = require("dapui.render.canvas")

return function(client)
  local dapui = { watches = {} }
  local send_ready = lib.create_render_loop(function()
    dapui.watches.render()
  end)

  local watches = require("dapui.components.watches")(client, send_ready)

  local buf = lib.create_buffer("DAP Watches", {
    filetype = "dapui_watches",
    omnifunc = "v:lua.require'dap'.omnifunc",
  })

  function dapui.watches.render()
    local canvas = Canvas.new()
    watches.render(canvas)
    canvas:render_buffer(buf, config.element_mapping("watches"))
  end

  function dapui.watches.buffer()
    return buf
  end

  return dapui.watches
end
