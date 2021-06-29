local M = {}
local listener_id = "dapui_hover"
local render = require("dapui.render")
local Hover = {
  eval = {win = nil},
  stack_frames = {}
}

function M.eval(expr)
  if Hover.eval.win ~= nil then
    Hover.eval.win:jump_to()
    return
  end
  local dap = require("dap")
  local session = dap.session()
  if not session then
    print("No active session to query")
    return
  end
  local filetype = (vim.fn.getbufvar(vim.fn.expand("%"), "&filetype"))
  local hover_win = require("dapui.windows.float").open_float({height = 1, width = 1})
  Hover.eval.win = hover_win
  vim.cmd("au CursorMoved * ++once lua require('dapui.hover').close_eval()")
  session:request(
    "evaluate",
    {
      expression = expr,
      frameId = session.current_frame.id,
      context = "hover"
    },
    function(_, response)
      if not response then
        print("Couldn't evaluate expression '" .. expr .. "' in current frame.")
        return
      end
      local render_state = render.new()
      for _, line in ipairs(vim.split(response.result, "\n")) do
        render_state:add_line(" " .. line .. " ")
      end
      local buf = hover_win:get_buf()
      hover_win:resize(render_state:width(), render_state:length())
      render.render_buffer(render_state, buf)
      vim.fn.setbufvar(buf, "&filetype", filetype)
      vim.api.nvim_buf_set_option(buf, "modifiable", false)
    end
  )
end

function M.close_eval()
  if Hover.eval.win == nil then
    return
  end
  local closed = Hover.eval.win:close(false)
  if not closed then
    vim.cmd("au CursorMoved * ++once lua require('dapui.hover').close_eval()")
  else
    Hover.eval.win = nil
  end
end

function M.setup(user_config)
  local dap = require("dap")

  dap.listeners.stackTrace[listener_id] = function(_, err, response)
    if not err then
      Hover.stack_frames = response.stackFrames
    end
  end
end

return M
