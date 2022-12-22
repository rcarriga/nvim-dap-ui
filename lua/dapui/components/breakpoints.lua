local config = require("dapui.config")
local async = require("dapui.async")
local util = require("dapui.util")

---@param client dapui.DAPClient
return function(client, send_ready)
  local _disabled_breakpoints = {}

  for _, event in ipairs({
    "setBreakpoints",
    "setFunctionBreakpoints",
    "setInstructionBreakpoints",
    "setDataBreakpoints",
    "stackTrace",
  }) do
    client.listen[event](function()
      send_ready()
    end)
  end

  ---@param bp dapui.types.DAPBreakpoint
  local function _toggle(bufnr, bp)
    require("dap.breakpoints").toggle({
      condition = bp.condition,
      hit_condition = bp.hitCondition,
      log_message = bp.logMessage,
    }, bufnr, bp.line)

    local buffer_breakpoints = require("dap.breakpoints").get(bufnr)
    local enabled = false
    for _, buf_bp in ipairs(buffer_breakpoints) do
      if buf_bp.line == bp.line then
        enabled = true
        break
      end
    end

    if not _disabled_breakpoints[bufnr] then
      _disabled_breakpoints[bufnr] = {}
    end

    if not enabled then
      bp.enabled = false
      _disabled_breakpoints[bufnr][bp.line] = bp
    else
      _disabled_breakpoints[bufnr][bp.line] = nil
    end
    send_ready()
  end

  ---@return table<integer, dapui.types.DAPBreakpoint[]>
  local function _get_breakpoints()
    ---@type table<integer, dapui.types.DAPBreakpoint[]>
    local bps = require("dap.breakpoints").get() or {}
    local merged_breakpoints = {}
    local buffers = {}
    for buf, _ in pairs(bps) do
      buffers[buf] = true
    end
    for bufnr, _ in pairs(_disabled_breakpoints) do
      buffers[bufnr] = true
    end
    for bufnr, _ in pairs(buffers) do
      local buf_points = bps[bufnr] or {}
      for _, bp in ipairs(buf_points) do
        bp.enabled = true
        if _disabled_breakpoints[bufnr] then
          _disabled_breakpoints[bufnr][bp.line] = nil
        end
      end
      merged_breakpoints[bufnr] = buf_points
      for _, bp in pairs(_disabled_breakpoints[bufnr] or {}) do
        table.insert(merged_breakpoints[bufnr], bp)
      end
      table.sort(merged_breakpoints[bufnr], function(a, b)
        return a.line < b.line
      end)
    end
    return merged_breakpoints
  end

  return {
    ---@param canvas dapui.Canvas
    render = function(canvas)
      local current_frame = client.session.current_frame
      local current_line = 0
      local current_file = ""
      if current_frame and current_frame.source and current_frame.source.path then
        current_file = async.fn.bufname(current_frame.source.path)
        current_line = current_frame.line
      end
      local indent = config.windows().indent
      for buffer, breakpoints in pairs(_get_breakpoints()) do
        local bufname = async.fn.bufname(buffer)
        local name = util.pretty_name(bufname)
        canvas:write(name, { group = "DapUIBreakpointsPath" })
        canvas:write(":\n")

        for _, bp in ipairs(breakpoints) do
          local text = vim.api.nvim_buf_get_lines(buffer, bp.line - 1, bp.line, false)
          local jump_to_bp = util.partial(
            client.lib.jump_to_frame,
            { line = bp.line, column = 0, source = { path = bufname } }
          )
          if vim.tbl_count(text) ~= 0 then
            canvas:add_mapping(config.actions.OPEN, jump_to_bp)
            canvas:add_mapping(config.actions.TOGGLE, function()
              _toggle(buffer, bp)
            end)
            canvas:write(string.rep(" ", indent))
            local group
            if _disabled_breakpoints[buffer] and _disabled_breakpoints[buffer][bp.line] then
              group = "DapUIBreakpointsDisabledLine"
            elseif bp.line == current_line and name == current_file then
              group = "DapUIBreakpointsCurrentLine"
            else
              group = "DapUIBreakpointsLine"
            end
            canvas:write(tostring(bp.line), { group = group })
            canvas:write(" " .. vim.trim(text[1]) .. "\n")

            local info_indent = indent + #tostring(bp.line) + 1
            local whitespace = string.rep(" ", info_indent)

            local function add_info(message, data)
              canvas:add_mapping(config.actions.OPEN, jump_to_bp)
              canvas:write(whitespace)
              canvas:write(message, { group = "DapUIBreakpointsInfo" })
              canvas:write(" " .. data .. "\n")
            end

            if bp.logMessage then
              add_info("Log Message:", bp.logMessage)
            end
            if bp.condition then
              add_info("Condition:", bp.condition)
            end
            if bp.hitCondition then
              add_info("Hit Condition:", bp.hitCondition)
            end
          end
        end
        canvas:write("\n")
      end
      if canvas:length() > 1 then
        canvas:remove_line()
        canvas:remove_line()
      else
        canvas:write("")
      end
    end,
  }
end
