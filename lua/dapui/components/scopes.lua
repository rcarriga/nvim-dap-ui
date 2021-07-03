local state = require("dapui.state")
local config = require("dapui.config")

local Variables = require("dapui.components.variables")

--- @class Scopes
--- @field var_components table<number, Variables>
local Scopes = {}

function Scopes:new()
  local scopes = {var_components = {}}
  setmetatable(scopes, self)
  self.__index = self
  return scopes
end

function Scopes:render(render_state)
  for i, scope in pairs(state.scopes()) do
    render_state:add_match(
      "DapUIScope", render_state:length() + 1, 1, #scope.name
    )
    render_state:add_line(scope.name .. ":")
    local variables = state.variables(scope.variablesReference)
    if not variables then
      state.monitor(scope.variablesReference)
    else
      self:_get_var_component(i):render(
        render_state, variables, config.windows().indent
      )
    end
    if i < #state.scopes() then render_state:add_line() end
  end
end

function Scopes:_get_var_component(index)
  if not self.var_components[index] then
    self.var_components[index] = Variables()
  end
  return self.var_components[index]

end

---@return Scopes
return function() return Scopes:new() end
