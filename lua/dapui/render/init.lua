local M = {}

local canvas = require("dapui.render.canvas")
local render_loop = require("dapui.render.loop")

M.new_canvas = canvas.new
M.render_buffer = canvas.render_buffer

M.loop = render_loop

return M
