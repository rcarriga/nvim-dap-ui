local config = require("dapui.config")
---@param client dapui.DAPClient
return function(client, send_ready)
  local render_vars = require("dapui.components.variables")(client, send_ready)
  client.listen.stopped(send_ready)

  return {
    ---@param canvas dapui.Canvas
    render = function(canvas)
      local called = false
      local frame = client.session.current_frame
      if not frame then
        -- nvim-dap sets current frame after a stackTrace request
        client.listen.stackTrace(function()
          if not called then
            called = true
            send_ready()
          end
          return true
        end)
        return
      end
      -- TODO: Might need to reset variable state on frame change
      -- if frame.id ~= self.frame_id then
      --   self.frame_id = frame.id
      --   self.var_components = {}
      -- end

      local scopes = client.request.scopes({ frameId = frame.id }).scopes

      for i, scope in pairs(scopes) do
        canvas:write(scope.name, { group = "DapUIScope" })
        canvas:write(":\n")
        render_vars.render(canvas, scope.name, scope.variablesReference, config.windows().indent)
        if i < #scopes then
          canvas:write("\n")
        end
      end

      canvas:remove_line()
    end,
  }
end
