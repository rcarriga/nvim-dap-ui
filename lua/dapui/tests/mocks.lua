local dap = require("dap")
local Client = require("dapui.client")

local M = {}

---@class dapui.tests.mocks.ScopesArgs
---@field scopes table<integer, dapui.types.Scope[]>

---@param args dapui.tests.mocks.ScopesArgs
function M.scopes(args)
  ---@param request_args dapui.types.ScopesArguments
  ---@return dapui.types.ScopesResponse
  return function(request_args)
    local scopes = args.scopes[request_args.frameId]
    assert(scopes, "No scopes found for frameId " .. request_args.frameId)
    return {
      scopes = scopes,
    }
  end
end

---@class dapui.tests.mocks.EvaluateArgs
---@field expressions table<string, string|dapui.types.EvaluateResponse>
function M.evaluate(args)
  ---@param request_args dapui.types.EvaluateArguments
  ---@return dapui.types.EvaluateResponse
  return function(request_args)
    local result = args.expressions[request_args.expression]
    assert(result, "No expression found for " .. request_args.expression)
    if type(result) == "string" then
      return {
        result = result,
        variablesReference = 0,
      }
    end
    result.variablesReference = result.variablesReference or 0
    return result
  end
end

---@class dapui.tests.mocks.VariablesArgs
---@field variables table<integer, dapui.types.Variable[]>

---@param args dapui.tests.mocks.VariablesArgs
function M.variables(args)
  ---@param request_args dapui.types.VariablesArguments
  ---@return dapui.types.VariablesResponse
  return function(request_args)
    local variables = args.variables[request_args.variablesReference]
    assert(variables, "No variables for variablesReference: " .. request_args.variablesReference)
    return {
      variables = variables,
    }
  end
end

---@class dapui.tests.mocks.ThreadsArgs
---@field threads dapui.types.Thread[]

---@param args dapui.tests.mocks.ThreadsArgs
function M.threads(args)
  ---@return dapui.types.ThreadsResponse
  return function()
    return {
      threads = args.threads,
    }
  end
end

---@class dapui.tests.mocks.StackTracesArgs
---@field stack_traces table<integer, dapui.types.StackFrame[]>

---@param args dapui.tests.mocks.StackTracesArgs
function M.stack_traces(args)
  ---@param request_args dapui.types.StackTraceArguments
  ---@return dapui.types.StackTraceResponse
  return function(request_args)
    local stack_frames = args.stack_traces[request_args.threadId]
    assert(stack_frames, "No stack frames for threadId: " .. request_args.threadId)
    return {
      stackFrames = stack_frames,
    }
  end
end

---@class dapui.tests.mocks.ClientArgs
---@field requests dapui.DAPRequestsClient
---@field current_frame? dapui.types.StackFrame
---@field stopped_thread_id? integer

---@param args? dapui.tests.mocks.ClientArgs
---@return dapui.DAPClient
function M.client(args)
  args = args or { requests = {} }
  local session
  session = {
    seq = 0,
    stopped_thread_id = args.stopped_thread_id,
    current_frame = args.current_frame,
    set_breakpoints = function() end,

    request = function(_, command, request_args, callback)
      session.seq = session.seq + 1
      if not args.requests[command] then
        error("No request handler for " .. command)
      end
      local response = args.requests[command](request_args)
      for _, c in pairs(dap.listeners.before[command]) do
        c(session, nil, response, request_args)
      end
      callback(nil, response, session.seq)
      for _, c in pairs(dap.listeners.after[command]) do
        c(session, nil, response, request_args)
      end
    end,
  }

  ---@type table<integer, dapui.types.DAPBreakpoint[]>
  local breakpoints = {}

  return Client(function()
    return session
  end, {
    get = function(bufnr)
      if bufnr then
        return breakpoints[bufnr]
      end
      return breakpoints
    end,
    ---@param bp_args dapui.client.BreakpointArgs
    toggle = function(bp_args, bufnr, line)
      local buf_bps = breakpoints[bufnr] or {}
      for i, bp in ipairs(buf_bps) do
        if bp.line == line then
          table.remove(buf_bps, i)
          return
        end
      end

      ---@type dapui.types.DAPBreakpoint
      buf_bps[#buf_bps + 1] = {
        condition = bp_args.condition,
        hitCondition = bp_args.hit_condition,
        line = line,
        logMessage = bp_args.log_message,
      }
      breakpoints[bufnr] = buf_bps
    end,
  })
end

return M
