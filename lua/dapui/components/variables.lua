local config = require("dapui.config")
local util = require("dapui.util")
local partial = util.partial

---@class Variables
---@field expanded_children table
---@field child_components table<number, Variables>
---@field state UIState
---@field var_to_set table | nil
---@field mode "set" | nil
---@field rendered_step integer | nil
---@field rendered_vars table[] | nil
local Variables = {}

---@param client dapui.DAPClient
---@param send_ready function
return function(client, send_ready)
  local expanded_children = {}

  ---@type fun(value: string) | nil
  local prompt_func
  ---@type string | nil
  local prompt_fill
  local rendered_step = client.lib.step_number()
  ---@type table<string, dapui.types.Variable>
  local rendered_vars = {}

  local function reference_prefix(path, variable)
    if variable.variablesReference == 0 then
      return " "
    end
    return config.icons()[expanded_children[path] and "expanded" or "collapsed"]
  end

  ---@param path string
  local function rendered_value(path)
    return rendered_vars[path] and rendered_vars[path].value
  end

  ---@param canvas dapui.Canvas
  ---@param parent_path string
  ---@param parent_ref integer
  ---@param indent integer
  local function render(canvas, parent_path, parent_ref, indent)
    if not canvas.prompt and prompt_func then
      canvas:set_prompt("> ", prompt_func, { fill = prompt_fill })
    end
    indent = indent or 0
    local variables = client.request.variables({ variablesReference = parent_ref }).variables
    for _, variable in pairs(variables) do
      local var_path = parent_path .. "." .. variable.name

      canvas:write(string.rep(" ", indent))
      local prefix = reference_prefix(var_path, variable)
      canvas:write(prefix, { group = "DapUIDecoration" })
      canvas:write(" ")
      canvas:write(variable.name, { group = "DapUIVariable" })

      local var_type = util.render_type(variable.type)
      if #var_type > 0 then
        canvas:write(" ")
        canvas:write(var_type, { group = "DapUIType" })
      end

      local var_group
      if rendered_value(var_path) == variable.value then
        var_group = "DapUIValue"
      else
        var_group = "DapUIModifiedValue"
      end
      local function add_var_line(line)
        if variable.variablesReference > 0 then
          canvas:add_mapping(config.actions.EXPAND, function()
            expanded_children[var_path] = not expanded_children[var_path]
            send_ready()
          end)
          if variable.evaluateName then
            canvas:add_mapping(
              config.actions.REPL,
              partial(util.send_to_repl, variable.evaluateName)
            )
          end
        end
        canvas:add_mapping(config.actions.EDIT, function()
          prompt_func = function(new_value)
            client.lib.set_variable(parent_ref, variable, new_value)
            prompt_func = nil
            prompt_fill = nil
            send_ready()
          end
          prompt_fill = variable.value
          send_ready()
        end)
        canvas:write(line .. "\n", { group = var_group })
      end

      if #(variable.value or "") > 0 then
        canvas:write(" = ")
        local value_start = #canvas.lines[canvas:length()]
        local value = variable.value

        for _, line in ipairs(util.format_value(value_start, value)) do
          add_var_line(line)
        end
      else
        add_var_line(variable.value)
      end

      if expanded_children[var_path] and variable.variablesReference ~= 0 then
        render(canvas, var_path, variable.variablesReference, indent + config.windows().indent)
      end
    end
    if client.lib.step_number() ~= rendered_step then
      rendered_vars = variables
      rendered_step = client.lib.step_number()
    end
  end

  return { render = render }
end
