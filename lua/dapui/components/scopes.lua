local config = require("dapui.config")
---@param client dapui.DAPClient
return function(client, send_ready)
  local render_vars = require("dapui.components.variables")(client, send_ready)

  ---@type dapui.types.Scope[] | nil
  local scopes
  client.listen.scopes(function(args)
    scopes = args.response.scopes
    send_ready()
  end)
  local on_exit = function()
    scopes = nil
    send_ready()
  end
  client.listen.terminated(on_exit)
  client.listen.exited(on_exit)
  client.listen.disconnect(on_exit)

  return {
    ---@param canvas dapui.Canvas
    render = function(canvas)
      if not scopes then
        return
      end
      for i, scope in pairs(scopes) do
        canvas:write({ { scope.name, group = "DapUIScope" }, ":\n" })
        render_vars.render(canvas, scope.name, scope.variablesReference, config.render.indent)
        if i < #scopes then
          canvas:write("\n")
        end
      end

      canvas:remove_line()
    end,
  }
end
