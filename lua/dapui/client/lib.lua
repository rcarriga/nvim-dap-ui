local util = require("dapui.util")
local async = require("dapui.async")

---@param client dapui.DAPClient
return function(client)
  ---@class dapui.DAPClientLib
  local client_lib = {}

  ---@param frame dapui.types.StackFrame
  ---@param set_frame boolean Set the current frame of session to given frame
  function client_lib.jump_to_frame(frame, set_frame)
    if set_frame then
      client.session._frame_set(frame)
      return
    end
    local line = frame.line
    local column = frame.column
    local source = frame.source
    if not source then
      return
    end

    if (source.sourceReference or 0) > 0 then
      local buf = async.api.nvim_create_buf(false, true)
      local response = client.request.source({ sourceReference = source.sourceReference })
      if not response.content then
        util.notify("No source available for frame", vim.log.levels.WARN)
        return
      end
      async.api.nvim_buf_set_lines(buf, 0, 0, true, vim.split(response.content, "\n"))
      util.open_buf(buf, line, column)
      async.api.nvim_buf_set_option(buf, "bufhidden", "delete")
      async.api.nvim_buf_set_option(buf, "modifiable", false)
      return
    end

    if not source.path then
      util.notify("No source available for frame", vim.log.levels.WARN)
    end

    local path = source.path

    if not column or column == 0 then
      column = 1
    end

    local bufnr = vim.uri_to_bufnr(
      util.is_uri(path) and path or vim.uri_from_fname(vim.fn.fnamemodify(path, ":p"))
    )
    async.fn.bufload(bufnr)
    util.open_buf(bufnr, line, column)
  end

  return client_lib
end
