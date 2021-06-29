local state = require("dapui.state")
local config = require("dapui.config")

local Variables = require("dapui.components.variables")

--- @class Scopes
--- @field variables Variables
local Scopes = {}

function Scopes:new()
  local scopes = {variables = Variables()}
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
    self.variables:render(
      render_state, tostring(scope.variablesReference), config.windows().indent
    )
    if i < #state.scopes() then render_state:add_line() end
  end
end

---@return Scopes
return function() return Scopes:new() end
