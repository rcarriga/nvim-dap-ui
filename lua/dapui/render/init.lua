local M = {}

---@class dapui.Element
---@field render fun()
---@field float_defaults? fun(): table
---@field buffer fun(): integer

local canvas = require("dapui.render.canvas")

M.new_canvas = canvas.new

return M
