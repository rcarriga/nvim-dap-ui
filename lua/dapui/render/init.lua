local M = {}

local render_state = require("dapui.render.state")
local render_loop = require("dapui.render.loop")

M.new_state = render_state.new
M.render_buffer = render_state.render_buffer

M.loop = render_loop

return M
