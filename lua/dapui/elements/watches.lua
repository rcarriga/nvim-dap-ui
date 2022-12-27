local util = require("dapui.util")
local config = require("dapui.config")
local Canvas = require("dapui.render.canvas")

return function(client)
  local dapui = { elements = {} }

  ---@class dapui.elements.watches
  ---@toc_entry Watch Expressions
  ---@text
  --- Allows creation of expressions to watch the value of in the context of the
  --- current frame.
  --- This uses a prompt buffer for input. To enter a new expression, just enter
  --- insert mode and you will see a prompt appear. Press enter to submit
  ---
  --- Mappings:
  ---
  --- - `expand`: Toggle showing the children of an expression.
  --- - `remove`: Remove the watched expression.
  --- - `edit`: Edit an expression or set the value of a child variable.
  --- - `repl`: Send expression to REPL

  dapui.elements.watches = {}
  local send_ready = util.create_render_loop(function()
    dapui.elements.watches.render()
  end)

  local watches = require("dapui.components.watches")(client, send_ready)

  local buf = util.create_buffer("DAP Watches", {
    filetype = "dapui_watches",
    omnifunc = "v:lua.require'dap'.omnifunc",
  })

  function dapui.elements.watches.render()
    local canvas = Canvas.new()
    watches.render(canvas)
    canvas:render_buffer(buf, config.element_mapping("watches"))
  end

  function dapui.elements.watches.buffer()
    return buf
  end

  return dapui.elements.watches
end
