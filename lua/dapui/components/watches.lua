local config = require("dapui.config")
local util = require("dapui.util")

local partial = util.partial

---@class dapui.watches.Watch
---@field expression string
---@field expanded boolean

---@param client dapui.DAPClient
return function(client, send_ready)
  local running = false
  client.listen.scopes(function()
    running = true
    send_ready()
  end)
  local on_exit = function()
    running = false
    send_ready()
  end

  client.listen.terminated(on_exit)
  client.listen.exited(on_exit)
  client.listen.disconnect(on_exit)

  ---@type dapui.watches.Watch[]
  local watches = {}
  local edit_index = nil
  local rendered_exprs = {}
  local rendered_step = client.lib.step_number()
  local render_vars = require("dapui.components.variables")(client, send_ready)

  local function add_watch(value)
    if #value > 0 then
      watches[#watches + 1] = {
        expression = value,
        expanded = false,
      }
      send_ready()
    end
  end

  local function edit_expr(new_value, index)
    index = index or edit_index
    edit_index = nil
    if #new_value > 0 then
      watches[index].expression = new_value
    end
    send_ready()
  end

  local function remove_expr(expr_i)
    table.remove(watches, expr_i)
    send_ready()
  end

  local function toggle_expression(expr_i)
    watches[expr_i].expanded = not watches[expr_i].expanded
    send_ready()
  end

  return {
    add = add_watch,
    edit = edit_expr,
    remove = remove_expr,
    get = function()
      return vim.deepcopy(watches)
    end,
    expand = toggle_expression,
    ---@param canvas dapui.Canvas
    render = function(canvas)
      if not edit_index then
        canvas:set_prompt("> ", add_watch)
      else
        canvas:set_prompt("> ", edit_expr, { fill = watches[edit_index].expression })
      end

      if vim.tbl_count(watches) == 0 then
        canvas:write("No Expressions\n", { group = "DapUIWatchesEmpty" })
        return
      end
      local frame_id = client.session
        and client.session.current_frame
        and client.session.current_frame.id
      local step = client.lib.step_number()
      for i, watch in pairs(watches) do
        local success, evaluated
        if running then
          success, evaluated = pcall(
            client.request.evaluate,
            { context = "watch", expression = watch.expression, frameId = frame_id }
          )
        else
          success, evaluated = false, { message = "No active session" }
        end
        local prefix = config.icons[watch.expanded and "expanded" or "collapsed"]

        canvas:write({
          { prefix, group = success and "DapUIWatchesValue" or "DapUIWatchesError" },
          " " .. watch.expression,
        })

        local value = ""
        if not success then
          watch.expanded = false
          canvas:write(": ")
          value = util.format_error(evaluated)
        else
          local eval_type = util.render_type(evaluated.type)
          if #eval_type > 0 then
            canvas:write({ " ", { eval_type, group = "DapUIType" } })
          end
          canvas:write(" = ")
          value = evaluated.result
        end
        local val_start = canvas:line_width()
        local var_group

        if not success or rendered_exprs[i] == evaluated.result then
          var_group = "DapUIValue"
        else
          var_group = "DapUIModifiedValue"
        end

        for _, line in ipairs(util.format_value(val_start, value)) do
          canvas:write(line, { group = var_group })
          canvas:add_mapping("remove", partial(remove_expr, i))
          canvas:add_mapping("edit", function()
            edit_index = i
            send_ready()
          end)
          if success then
            canvas:add_mapping("expand", partial(toggle_expression, i))
            canvas:add_mapping("repl", partial(util.send_to_repl, watch.expression))
          end
          canvas:write("\n")
        end

        local var_ref = success and evaluated.variablesReference or 0
        if watch.expanded and var_ref > 0 then
          render_vars.render(canvas, watch.expression, var_ref, config.render.indent)
        end
        if rendered_step ~= step then
          rendered_exprs[i] = evaluated.result
        end
      end
      if rendered_step ~= step then
        rendered_step = step
      end
    end,
  }
end
