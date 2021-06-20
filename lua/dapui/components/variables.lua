local M = {}

local state = require("dapui.state")
local config = require("dapui.config")

--- @class Variables
--- @field mark_variable_map table
--- @field expanded_references table
local Variables = {}

function Variables:new()
  local elem = {mark_variable_map = {}, expanded_references = {}}
  setmetatable(elem, self)
  self.__index = self
  state.on_clear(function() elem.expanded_references = {} end)
  return elem
end

function Variables:render(render_state, ref_path, indent, expanded)
  expanded = expanded or {}
  indent = indent or config.windows().indent
  expanded[ref_path] = true
  local var_ref = self:_var_ref_from_path(ref_path)
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

    if #(variable.value or "") > 0 then
      new_line = new_line .. " = "
      local value_start = #new_line
      new_line = new_line .. variable.value

      for i, line in pairs(vim.split(new_line, "\n")) do
        if i > 1 then line = string.rep(" ", value_start - 2) .. line end
        render_state:add_line(line)
        self.mark_variable_map[render_state:add_mark()] = var_reference_path
      end
    else
      render_state:add_line(new_line)
      self.mark_variable_map[render_state:add_mark()] = var_reference_path
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

function Variables:toggle_reference(mark_id)
  local current_ref_path = self.mark_variable_map[mark_id]
  if not current_ref_path then return end

  local session = require("dap").session()
  if not session then
    print("No active session to query")
    return
  end

  local current_ref = self:_var_ref_from_path(current_ref_path)

  if self.expanded_references[current_ref_path] then
    self.expanded_references[current_ref_path] = nil
    state.stop_monitor(current_ref)
  else
    self.expanded_references[current_ref_path] = true
    state.monitor(current_ref)
  end
end

function Variables:_var_ref_from_path(ref_path)
  local var_path_elems = vim.split(ref_path, "/")
  return tonumber(var_path_elems[#var_path_elems])
end

function Variables:_reference_prefix(ref_path)
  if vim.endswith(ref_path, "/0") then return " " end
  return config.icons()[self.expanded_references[ref_path] and "expanded" or
           "collapsed"]
end

function M.new() return Variables:new() end

return M
