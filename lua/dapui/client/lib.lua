local util = require("dapui.util")
local nio = require("nio")

---@param client dapui.DAPClient
return function(client)
  ---@class dapui.DAPClientLib
  local client_lib = {}

  ---@param frame dapui.types.StackFrame
  ---@param set_frame boolean Set the current frame of session to given frame
  function client_lib.jump_to_frame(frame, set_frame)
    local opened = (function()
      local line = frame.line
      local column = frame.column
      local source = frame.source
      if not source then
        return
      end

      if (source.sourceReference or 0) > 0 then
        local buf = nio.api.nvim_create_buf(false, true)
        local response = client.request.source({ sourceReference = source.sourceReference })
        if not response.content then
          util.notify("No source available for frame", vim.log.levels.WARN)
          return
        end
        nio.api.nvim_buf_set_lines(buf, 0, 0, true, vim.split(response.content, "\n"))
        nio.api.nvim_buf_set_option(buf, "bufhidden", "delete")
        nio.api.nvim_buf_set_option(buf, "modifiable", false)
        return util.open_buf(buf, line, column)
      end

      if not source.path or not vim.uv.fs_stat(source.path) then
        util.notify("No source available for frame", vim.log.levels.WARN)
        return
      end

      local path = source.path

      if not column or column == 0 then
        column = 1
      end

      local bufnr = vim.uri_to_bufnr(
        util.is_uri(path) and path or vim.uri_from_fname(vim.fn.fnamemodify(path, ":p"))
      )
      nio.fn.bufload(bufnr)
      return util.open_buf(bufnr, line, column)
    end)()
    if opened and set_frame then
      client.session._frame_set(frame)
    end
  end

  ---@param variable dapui.types.Variable
  function client_lib.set_variable(container_ref, variable, value)
    local ok, err = pcall(function()
      if client.session.capabilities.supportsSetExpression and variable.evaluateName then
        local frame_id = client.session.current_frame and client.session.current_frame.id
        client.request.setExpression({
          expression = variable.evaluateName,
          value = value,
          frameId = frame_id,
        })
      elseif client.session.capabilities.supportsSetVariable and container_ref then
        client.request.setVariable({
          variablesReference = container_ref,
          name = variable.name,
          value = value,
        })
      else
        util.notify(
          "Debug server doesn't support setting " .. (variable.evaluateName or variable.name),
          vim.log.levels.WARN
        )
      end
    end)
    if not ok then
      util.notify(util.format_error(err))
    end
  end

  local stop_count = 0
  client.listen.stopped(function()
    stop_count = stop_count + 1
  end)
  client.listen.initialized(function()
    stop_count = 0
  end)

  ---@return integer: The number of times the debugger has stopped
  function client_lib.step_number()
    return stop_count
  end

  return client_lib
end
