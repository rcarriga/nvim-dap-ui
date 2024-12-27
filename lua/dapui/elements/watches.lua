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
  dapui.elements.watches = {
    allow_without_session = true,
  }

  local send_ready = util.create_render_loop(function()
    dapui.elements.watches.render()
  end)

  local watches = require("dapui.components.watches")(client, send_ready)

  --- Add a new watch expression
  ---@param expr? string
  function dapui.elements.watches.add(expr)
    if not expr then
      expr = util.get_current_expr()
    end
    watches.add(expr)
  end

  --- Change the chosen watch expression
  ---@param index integer
  ---@param new_expr string
  function dapui.elements.watches.edit(index, new_expr)
    watches.edit(new_expr, index)
  end

  --- Remove the chosen watch expression
  function dapui.elements.watches.remove(index)
    watches.remove(index)
  end

  --- Get the current list of watched expressions
  ---@return dapui.elements.watches.Watch[]
  function dapui.elements.watches.get()
    return watches.get()
  end

  ---@class dapui.elements.watches.Watch
  ---@field expression string
  ---@field expanded boolean

  --- Toggle the expanded state of the chosen watch expression
  ---@param index integer
  function dapui.elements.watches.toggle_expand(index)
    watches.expand(index)
  end

  ---@nodoc
  function dapui.elements.watches.render()
    local canvas = Canvas.new()
    watches.render(canvas)
    canvas:render_buffer(dapui.elements.watches.buffer(), config.element_mapping("watches"))
  end

  ---@nodoc
  dapui.elements.watches.buffer = util.create_buffer("DAP Watches", {
    filetype = "dapui_watches",
    omnifunc = "v:lua.require'dap'.omnifunc",
  })

  return dapui.elements.watches
end
