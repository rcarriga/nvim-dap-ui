local state = require("dapui.state")
local config = require("dapui.config")
local partial = require("dapui.util").partial

--- @class Variables
--- @field expanded_references table
local Variables = {}

function Variables:new()
  local elem = {expanded_references = {}}
  setmetatable(elem, self)
  self.__index = self
  state.on_clear(function() elem.expanded_references = {} end)
  return elem
end

function Variables:toggle_reference(ref, ref_path)
  self.expanded_references[ref_path] = not self.expanded_references[ref_path]
  if not self.expanded_references[ref_path] then
    state.stop_monitor(ref)
  else
    state.monitor(ref)
  end
end

function Variables:render(render_state, ref_path, indent, expanded)
  expanded = expanded or {}
  indent = indent or 0
  expanded[ref_path] = true
  local var_path_elems = vim.split(ref_path, "/")
  local var_ref = tonumber(var_path_elems[#var_path_elems])
  for _, variable in pairs(state.variables(var_ref)) do
    local line_no = render_state:length() + 1
    local var_reference_path = ref_path .. "/" .. variable.variablesReference

    local new_line = string.rep(" ", indent)
    local prefix = self:_reference_prefix(var_reference_path)
    render_state:add_match("DapUIDecoration", line_no, #new_line + 1, 1)
    new_line = new_line .. prefix .. " "

    render_state:add_match(
      "DapUIVariable", line_no, #new_line + 1, #variable.name
    )
    new_line = new_line .. variable.name

    if #(variable.type or "") > 0 then
      new_line = new_line .. " "
      render_state:add_match("DapUIType", line_no, #new_line + 1, #variable.type)
      new_line = new_line .. variable.type
    end

    local function add_var_line(line)
      render_state:add_line(line)
      if variable.variablesReference > 0 then
        render_state:add_mapping(
          config.actions.EXPAND, partial(
            Variables.toggle_reference, self, variable.variablesReference,
            var_reference_path
          )
        )
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

    if self.expanded_references[var_reference_path] and
      not expanded[var_reference_path] then
      self:render(
        render_state, var_reference_path, indent + config.windows().indent,
        expanded
      )
    end
  end
end

function Variables:_reference_prefix(ref_path)
  if vim.endswith(ref_path, "/0") then return " " end
  return config.icons()[self.expanded_references[ref_path] and "expanded" or
           "collapsed"]
end

---@return Variables
return partial(Variables.new, Variables)
