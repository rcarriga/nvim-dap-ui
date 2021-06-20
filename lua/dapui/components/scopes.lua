local M = {}

local state = require("dapui.state")

--- @class Scopes
--- @field variables Variables
local Scopes = {}

--- @param variables Variables
function Scopes:new(variables)
  local elem = {
    variables = variables
  }
  setmetatable(elem, self)
  self.__index = self
  return elem
end

function Scopes:render(render_state)
  for i, scope in pairs(state.scopes()) do
    render_state:add_match("DapUIScope", render_state:length() + 1, 1, #scope.name)
    render_state:add_line(scope.name .. ":")
    self.variables:render(render_state, tostring(scope.variablesReference))
    if i < #state.scopes() then
      render_state:add_line()
    end
  end
end

---@param variables Variables
function M.new(variables)
  return Scopes:new(variables)
end

return M
