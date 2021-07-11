local config = require("dapui.config")
local partial = require("dapui.util").partial

---@class Variables
---@field expanded_children table
---@field child_components table<number, Variables>
---@field state UIState
local Variables = {}

function Variables:new(state)
  local elem = {expanded_children = {}, child_components = {}, state = state}
  setmetatable(elem, self)
  self.__index = self
  state:on_clear(function() elem.expanded_references = {} end)
  return elem
end

function Variables:toggle_reference(ref, index)
  self.expanded_children[index] = not self.expanded_children[index]
  if not self.expanded_children[index] then
    self.state:stop_monitor(ref)
  else
    self.state:monitor(ref)
  end
end

function Variables:render(render_state, variables, indent)
  indent = indent or 0
  for index, variable in pairs(variables) do
    local line_no = render_state:length() + 1

    local new_line = string.rep(" ", indent)
    local prefix = self:_reference_prefix(index, variable)
    render_state:add_match("DapUIDecoration", line_no, #new_line + 1, 1)
    new_line = new_line .. prefix .. " "

    render_state:add_match("DapUIVariable", line_no, #new_line + 1,
                           #variable.name)
    new_line = new_line .. variable.name

    if #(variable.type or "") > 0 then
      new_line = new_line .. " "
      render_state:add_match("DapUIType", line_no, #new_line + 1, #variable.type)
      new_line = new_line .. variable.type
    end

    local function add_var_line(line)
      render_state:add_line(line)
      if variable.variablesReference > 0 then
        render_state:add_mapping(config.actions.EXPAND, partial(
          Variables.toggle_reference, self, variable.variablesReference, index))
      end
    end

    if #(variable.value or "") > 0 then
      new_line = new_line .. " = "
      local value_start = #new_line
      new_line = new_line .. variable.value

      for i, line in pairs(vim.split(new_line, "\n")) do
        if i > 1 then line = string.rep(" ", value_start - 2) .. line end
        add_var_line(line)
      end
    else
      add_var_line(new_line)
    end

    if self.expanded_children[index] then
      local child_vars = self.state:variables(variable.variablesReference)
      if not child_vars then
        self.state:monitor(variable.variablesReference)
        render_state:invalidate()
        return
      else
        self:_get_child_component(index):render(render_state, child_vars,
                                                indent + config.windows().indent)
      end
    end
  end
end

function Variables:_get_child_component(index)
  if not self.child_components[index] then
    self.child_components[index] = Variables:new(self.state)
  end
  return self.child_components[index]
end

function Variables:_reference_prefix(index, variable)
  if variable.variablesReference == 0 then return " " end
  return config.icons()[self.expanded_children[index] and "expanded" or
           "collapsed"]
end

---@param state UIState
---@return Variables
return function(state) return Variables:new(state) end
