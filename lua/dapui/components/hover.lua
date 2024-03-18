local config = require("dapui.config")
local util = require("dapui.util")

---@class Hover
---@field expression string
---@field expanded boolean
---@field var_component Variables
---@field mode "set" | nil
local Hover = {}

---@param client dapui.DAPClient
return function(client, send_ready)
  ---@return Hover
  local expression
  local expr_context = "hover"
  local expanded = false
  local render_vars = require("dapui.components.variables")(client, send_ready)
  local prompt_func

  return {
    set_expression = function(new_expr, context)
      expression = new_expr
      expr_context = context or "hover"
      send_ready()
    end,
    ---@param canvas dapui.Canvas
    render = function(canvas)
      local frame = client.session and client.session.current_frame
      if not frame then
        return
      end
      if not expression then
        return
      end

      if prompt_func then
        canvas:set_prompt("> ", prompt_func, { fill = expression })
      end

      local success, hover_expr = pcall(
        client.request.evaluate,
        { expression = expression, context = expr_context, frameId = frame.id }
      )

      local var_ref = success and hover_expr.variablesReference

      local prefix
      if not success or hover_expr.variablesReference > 0 then
        prefix = config.icons[expanded and "expanded" or "collapsed"] .. " "
        canvas:write(prefix, { group = success and "DapUIDecoration" or "DapUIWatchesError" })
      end

      canvas:write(expression)

      local val_start = 0
      local value
      if not success then
        canvas:write(": ")
        val_start = canvas:line_width()
        --- Fails formatting if it isn't a DAP error
        value = util.format_error(hover_expr) or error(hover_expr)
      elseif hover_expr then
        local eval_type = util.render_type(hover_expr.type)
        if #eval_type > 0 then
          canvas:write(" ")
          canvas:write(eval_type, { group = "DapUIType" })
        end
        canvas:write(" = ")
        val_start = canvas:line_width()
        value = hover_expr.result
      else
        return
      end
      for _, line in ipairs(util.format_value(val_start, value)) do
        canvas:write(line, { group = "DapUIValue" })
        if success then
          canvas:add_mapping("expand", function()
            expanded = not expanded
            send_ready()
          end)
          canvas:add_mapping("repl", util.partial(util.send_to_repl, expression))
        end
        canvas:add_mapping("edit", function()
          prompt_func = function(new_expr)
            expression = new_expr
            prompt_func = prompt_func
            send_ready()
          end
          send_ready()
        end)
        canvas:write("\n")
      end

      if expanded and var_ref then
        render_vars.render(canvas, expression, var_ref, config.render.indent)
      end
      canvas:remove_line()
    end,
  }
end
