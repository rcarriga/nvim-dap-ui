local config = require("dapui.config")
---@param client dapui.DAPClient
return function(client, send_ready)
  local render_vars = require("dapui.components.variables")(client, send_ready)

  ---@type dapui.types.Scope[] | nil
  local _scopes
  client.listen.scopes(function(args)
    if args.response then
      _scopes = args.response.scopes
    end
    send_ready()
  end)
  local on_exit = function()
    _scopes = nil
    send_ready()
  end
  client.listen.terminated(on_exit)
  client.listen.exited(on_exit)
  client.listen.disconnect(on_exit)

  return {
    ---@param canvas dapui.Canvas
    render = function(canvas)
      -- In case scopes are wiped during render
      local scopes = _scopes
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
