local config = require("dapui.config")
local frame_renderer = require("dapui.components.frames")

---@param client dapui.DAPClient
---@param send_ready function
return function(client, send_ready)
  ---@type dapui.types.Thread[] | nil
  local _threads = nil

  client.listen.threads(function(args)
    _threads = args.response.threads
  end)
  client.listen.scopes(function()
    send_ready()
  end)

  local on_exit = function()
    _threads = nil
    send_ready()
  end
  client.listen.terminated(on_exit)
  client.listen.exited(on_exit)
  client.listen.disconnect(on_exit)

  local render_frames = frame_renderer(client, send_ready)
  local subtle_threads = {}
  return {
    ---@param canvas dapui.Canvas
    render = function(canvas, indent)
      -- In case threads are wiped during render
      local threads = _threads
      local session = client.session
      if not threads or not session then
        return
      end

      indent = indent or 0

      ---@param thread dapui.types.Thread
      local function render_thread(thread, match_group)
        local first_line = canvas:length()

        canvas:write({ { thread.name, group = match_group }, ":\n" })

        render_frames.render(
          canvas,
          thread.id,
          subtle_threads[thread.id] or false,
          indent + config.render.indent
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

      local stopped_thread_id = session.stopped_thread_id

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
