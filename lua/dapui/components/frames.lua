local config = require("dapui.config")
local util = require("dapui.util")

---@param client dapui.DAPClient
return function(client, send_ready)
  client.listen.scopes(send_ready)
  client.listen.terminated(send_ready)
  client.listen.exited(send_ready)
  client.listen.disconnect(send_ready)

  return {
    ---@async
    ---@param canvas dapui.Canvas
    render = function(canvas, thread_id, show_subtle, indent)
      if not client.session then
        return
      end

      local current_frame_id = nil

      local threads = client.session.threads

      if not threads or not threads[thread_id] then
        return
      end

      local frames = threads[thread_id].frames
      if not frames then
        local success, response = pcall(client.request.stackTrace, { threadId = thread_id })
        frames = success and response.stackFrames
      end
      if not frames then
        return
      end

      if not show_subtle then
        frames = vim.tbl_filter(function(frame)
          return frame.presentationHint ~= "subtle"
        end, frames)
      end

      if client.session then
        current_frame_id = client.session.current_frame and client.session.current_frame.id
      end

      for _, frame in ipairs(frames) do
        local is_current = frame.id == current_frame_id
        canvas:write(string.rep(" ", is_current and (indent - 1) or indent))

        if is_current then
          canvas:write(config.icons.current_frame .. " ")
        end

        canvas:write(
          frame.name,
          { group = frame.id == current_frame_id and "DapUICurrentFrameName" or "DapUIFrameName" }
        )
        canvas:write(" ")

        if frame.source ~= nil then
          local file_name = frame.source.name or frame.source.path or "<unknown>"
          local source_name = util.pretty_name(file_name)
          canvas:write(source_name, { group = "DapUISource" })
        end

        if frame.line ~= nil then
          canvas:write(":")
          canvas:write(frame.line, { group = "DapUILineNumber" })
        end
        canvas:add_mapping("open", util.partial(client.lib.jump_to_frame, frame, true))
        canvas:write("\n")
      end

      canvas:remove_line()
    end,
  }
end
