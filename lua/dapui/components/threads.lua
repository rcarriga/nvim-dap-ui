local config = require("dapui.config")
local frame_renderer = require("dapui.components.frames")

---@param client dapui.DAPClient
---@param send_ready function
return function(client, send_ready)
  client.listen.stopped(send_ready)
  local render_frames = frame_renderer(client, send_ready)
  local subtle_threads = {}
  return {
    ---@param canvas dapui.Canvas
    render = function(canvas, indent)
      indent = indent or 0
      local threads = client.request.threads().threads

      ---@param thread dapui.types.Thread
      local function render_thread(thread, match_group)
        local first_line = canvas:length()

        canvas:write(thread.name, { group = match_group })
        canvas:write(":\n")

        render_frames.render(
          canvas,
          thread.id,
          subtle_threads[thread.id] or false,
          indent + config.windows().indent
        )

        local last_line = canvas:length()

        for line = first_line, last_line, 1 do
          canvas:add_mapping("toggle", function()
            subtle_threads[thread.id] = not subtle_threads[thread.id]
            send_ready()
          end, { line = line })
        end

        canvas:write("\n\n")
      end

      local stopped_thread_id = client.session.stopped_thread_id

      for _, thread in pairs(threads) do
        if thread.id == stopped_thread_id then
          render_thread(thread, "DapUIStoppedThread")
        end
      end
      for _, thread in pairs(threads) do
        if thread.id ~= stopped_thread_id then
          render_thread(thread, "DapUIThread")
        end
      end

      -- canvas:remove_line()
      -- canvas:remove_line()
    end,
  }
end
