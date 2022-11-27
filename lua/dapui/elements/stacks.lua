local config = require("dapui.config")
local Canvas = require("dapui.render.canvas")
local lib = require("dapui.lib")

return function(client)
  local dapui = { stacks = {} }
  local send_ready = lib.create_render_loop(function()
    dapui.stacks.render()
  end)

  local threads = require("dapui.components.threads")(client, send_ready)

  local buf = lib.create_buffer("DAP Stacks", {
    filetype = "dapui_stacks",
  })

  function dapui.stacks.render()
    local canvas = Canvas.new()
    threads.render(canvas)
    canvas:render_buffer(buf, config.element_mapping("stacks"))
  end

  function dapui.stacks.buffer()
    return buf
  end

  return dapui.stacks
end
