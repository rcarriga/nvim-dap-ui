local config = require("dapui.config")
---@param client dapui.DAPClient
return function(client, send_ready)
  local render_vars = require("dapui.components.variables")(client, send_ready)
  local closed_scopes = {}

  ---@param scope dapui.types.Scope
  local function scope_prefix(scope)
    if scope.indexedVariables == 0 then
      return " "
    end
    return config.icons[closed_scopes[scope.name] and "collapsed" or "expanded"]
  end

  ---@type dapui.types.Scope[] | nil
  local _scopes
  client.listen.scopes(function(args)
    if args.response then
      _scopes = args.response.scopes
      -- when new scopes are parsed, automatically disable the scopes that are too expensive to render
      for _, scope in ipairs(_scopes) do
        if scope.expensive then
          closed_scopes[scope.name] = true
        end
      end
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
        canvas:add_mapping("expand", function()
          closed_scopes[scope.name] = not closed_scopes[scope.name]
          send_ready()
        end)

        canvas:write({
          { scope_prefix(scope), group = "DapUIDecoration" },
          " ",
          { scope.name, group = "DapUIScope" },
          { ":\n" },
        })

        -- only render expanded scopes to save resources
        if not closed_scopes[scope.name] then
          render_vars.render(canvas, scope.name, scope.variablesReference, config.render.indent)
        end

        if i < #scopes then
          canvas:write("\n")
        end
      end

      canvas:remove_line()
    end,
  }
end
