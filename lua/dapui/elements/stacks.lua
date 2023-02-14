local config = require("dapui.config")
local Canvas = require("dapui.render.canvas")
local util = require("dapui.util")

return function(client)
  local dapui = { elements = {} }

  ---@class dapui.elements.stacks
  ---@toc_entry Threads and Stack Frames
  ---@text
  --- Displays the running threads and their stack frames.
  ---
  --- Mappings:
  --- - `open`: Jump to a place within the stack frame.
  --- - `toggle`: Toggle displaying subtle frames
  dapui.elements.stacks = {}

  local send_ready = util.create_render_loop(function()
    dapui.elements.stacks.render()
  end)

  local threads = require("dapui.components.threads")(client, send_ready)

  ---@nodoc
  function dapui.elements.stacks.render()
    local canvas = Canvas.new()
    threads.render(canvas)
    canvas:render_buffer(dapui.elements.stacks.buffer(), config.element_mapping("stacks"))
  end

  ---@nodoc
  dapui.elements.stacks.buffer = util.create_buffer("DAP Stacks", {
    filetype = "dapui_stacks",
  })

  return dapui.elements.stacks
end
