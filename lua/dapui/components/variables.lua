local config = require("dapui.config")
local util = require("dapui.util")
local partial = util.partial
local nio = require("nio")

---@class Variables
---@field frame_expanded_children table
---@field child_components table<number, Variables>
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
  ---@type table<string, string>
  local rendered_vars = {}

  local function reference_prefix(path, variable)
    if variable.variablesReference == 0 then
      return " "
    end
    return config.icons[expanded_children[path] and "expanded" or "collapsed"]
  end

  ---@param path string
  local function path_changed(path, value)
    return rendered_vars[path] and rendered_vars[path] ~= value
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
    local success, var_data = pcall(client.request.variables, { variablesReference = parent_ref })
    local variables = success and var_data.variables or {}
    if config.render.sort_variables then
      table.sort(variables, config.render.sort_variables)
    end
    for _, variable in pairs(variables) do
      local var_path = parent_path .. "." .. variable.name

      canvas:write({
        string.rep(" ", indent),
        { reference_prefix(var_path, variable), group = "DapUIDecoration" },
        " ",
        { variable.name, group = "DapUIVariable" },
      })

      local var_type = util.render_type(variable.type)
      if #var_type > 0 then
        canvas:write({ " ", { var_type, group = "DapUIType" } })
      end

      local var_group
      if path_changed(var_path, variable.value) then
        var_group = "DapUIModifiedValue"
      else
        var_group = "DapUIValue"
      end
      rendered_vars[var_path] = variable.value
      local function add_var_line(line)
        if variable.variablesReference > 0 then
          canvas:add_mapping("expand", function()
            expanded_children[var_path] = not expanded_children[var_path]
            send_ready()
          end)
          if variable.evaluateName then
            canvas:add_mapping("repl", partial(util.send_to_repl, variable.evaluateName))
          end
        end
        canvas:add_mapping("edit", function()
          prompt_func = function(new_value)
            nio.run(function()
              prompt_func = nil
              prompt_fill = nil
              client.lib.set_variable(parent_ref, variable, new_value)
              send_ready()
            end)
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
        render(canvas, var_path, variable.variablesReference, indent + config.render.indent)
      end
    end
  end

  return {
    render = render,
  }
end
