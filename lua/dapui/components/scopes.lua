local config = require("dapui.config")
local Variables = require("dapui.components.variables")

---@class Scopes
---@field frame_id string
---@field var_components table<number, Variables>
---@field state UIState
local Scopes = {}

function Scopes:new(state)
  local scopes = { frame_id = nil, var_components = {}, state = state }
  setmetatable(scopes, self)
  self.__index = self
  return scopes
end

function Scopes:render(render_state)
  local frame = self.state:current_frame()
  if not frame then
    render_state:invalidate()
    return
  end
  if frame.id ~= self.frame_id then
    self.frame_id = frame.id
    self.var_components = {}
  end
  for i, scope in pairs(self.state:scopes()) do
    render_state:add_match("DapUIScope", render_state:length() + 1, 1, #scope.name)
    render_state:add_line(scope.name .. ":")
    local variables = self.state:variables(scope.variablesReference)
    if not variables then
      render_state:invalidate()
    else
      self
        :_get_var_component(i)
        :render(render_state, scope.variablesReference, variables, config.windows().indent)
    end
    if i < #self.state:scopes() then
      render_state:add_line()
    end
  end
end

function Scopes:_get_var_component(index)
  if not self.var_components[index] then
    self.var_components[index] = Variables(self.state)
  end
  return self.var_components[index]
end

---@param state UIState
---@return Scopes
return function(state)
  return Scopes:new(state)
end
