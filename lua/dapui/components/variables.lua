local config = require("dapui.config")
local loop = require("dapui.render.loop")
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

function Variables:new(state)
  local elem = { expanded_children = {}, child_components = {}, state = state }
  setmetatable(elem, self)
  self.__index = self
  return elem
end

function Variables:toggle_reference(ref, name)
  self.expanded_children[name] = not self.expanded_children[name]
  if not self.expanded_children[name] then
    self.state:stop_monitor(ref)
  else
    self.state:monitor(ref)
  end
end

function Variables:set_var(parent_ref, value)
  self.state:set_variable(parent_ref, self.var_to_set, value)
  self.mode = nil
  self.var_to_set = nil
  loop.run()
end

---@param canvas dapui.Canvas
function Variables:render(canvas, parent_ref, variables, indent)
  if self.mode == "set" then
    canvas:set_prompt(
      "> ",
      partial(self.set_var, self, parent_ref),
      { fill = self.var_to_set.value }
    )
  end
  indent = indent or 0
  for var_index, variable in pairs(variables) do
    canvas:write(string.rep(" ", indent))
    local prefix = self:_reference_prefix(variable)
    canvas:write(prefix, { group = "DapUIDecoration" })
    canvas:write(" ")
    canvas:write(variable.name, { group = "DapUIVariable" })

    local var_type = util.render_type(variable.type)
    if #var_type > 0 then
      canvas:write(" ")
      canvas:write(var_type, { group = "DapUIType" })
    end

    local var_group
    if
      not self.rendered_vars
      or not self.rendered_vars[var_index]
      or self.rendered_vars[var_index].value == variable.value
    then
      var_group = "DapUIValue"
    else
      var_group = "DapUIModifiedValue"
    end
    local function add_var_line(line)
      if variable.variablesReference > 0 then
        canvas:add_mapping(
          config.actions.EXPAND,
          partial(Variables.toggle_reference, self, variable.variablesReference, variable.name)
        )
        if variable.evaluateName then
          canvas:add_mapping(config.actions.REPL, partial(util.send_to_repl, variable.evaluateName))
        end
      end
      canvas:add_mapping(config.actions.EDIT, function()
        self.mode = "set"
        self.var_to_set = variable
        loop.run()
      end)
      canvas:write(line .. "\n", { group = var_group })
    end

    if #(variable.value or "") > 0 then
      canvas:write(" = ")
      local value_start = #canvas.lines[canvas:length()]
      local value = variable.value

      for i, line in pairs(vim.split(value, "\n")) do
        if i > 1 then
          line = string.rep(" ", value_start - 2) .. line
        end
        add_var_line(line)
      end
    else
      add_var_line(variable.value)
    end

    if self.expanded_children[variable.name] and variable.variablesReference ~= 0 then
      local child_vars = self.state:variables(variable.variablesReference)
      if not child_vars then
        -- Happens when the parent component is collapsed and the variable
        -- reference changes when re-opened.  The name is recorded as opened
        -- but the variable reference is not yet monitored.
        if not self.state:is_monitored(variable.variablesReference) then
          self.state:monitor(variable.variablesReference)
        end
        return
      else
        self
          :_get_child_component(variable.name)
          :render(canvas, variable.variablesReference, child_vars, indent + config.windows().indent)
      end
    end
  end
  if self.state:step_number() ~= self.rendered_step then
    self.rendered_vars = variables
    self.rendered_step = self.state:step_number()
  end
end

function Variables:_get_child_component(name)
  if not self.child_components[name] then
    self.child_components[name] = Variables:new(self.state)
  end
  return self.child_components[name]
end

function Variables:_reference_prefix(variable)
  if variable.variablesReference == 0 then
    return " "
  end
  return config.icons()[self.expanded_children[variable.name] and "expanded" or "collapsed"]
end

---@param state UIState
---@return Variables
return function(state)
  return Variables:new(state)
end
