local config = require("dapui.config")
local util = require("dapui.util")

---@param client dapui.DAPClient
return function(client, send_ready)
  client.listen.stopped(send_ready)
  return {
    ---@async
    ---@param canvas dapui.Canvas
    render = function(canvas, thread_id, subtle, indent)
      local frames = client.request.stackTrace({ threadId = thread_id }).stackFrames

      if not subtle then
        frames = vim.tbl_filter(function(frame)
          return frame.presentationHint ~= "subtle"
        end, frames)
      end

      local current_frame_id = client.session.current_frame and client.session.current_frame.id

      for _, frame in ipairs(frames) do
        local is_current = frame.id == client.session.current_frame
        canvas:write(string.rep(" ", is_current and (indent - 1) or indent))

        if is_current then
          canvas:write(config.icons().current_frame .. " ")
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
        canvas:add_mapping(config.actions.OPEN, util.partial(client.lib.jump_to_frame, frame))
        canvas:write("\n")
      end

      canvas:remove_line()
    end,
  }
end
