local dapui = {}
local tasks = require("dapui.async.tasks")
local control = require("dapui.async.control")
local uv = require("dapui.async.uv")
local tests = require("dapui.async.tests")
local ui = require("dapui.async.ui")
local lsp = require("dapui.async.lsp")

---@toc_entry Async Library
---@text
--- The API is heavily inspired by Python's asyncio module and is currently
--- experimental meaning that interfaces may change without warning.
--- Users of nvim-dap-ui should not need to use this module directly.
---@class dapui.async
dapui.async = {}

dapui.async.control = control
dapui.async.uv = uv
dapui.async.ui = ui
dapui.async.tests = tests
dapui.async.tasks = tasks
dapui.async.lsp = lsp

--- Run a function in an async context. This is the entrypoint to all async
--- functionality.
--- ```lua
---   local async = require("dapui").async
---   async.run(function()
---     async.sleep(10)
---     print("Hello world")
---   end)
--- ```
---@param func function
---@return dapui.async.tasks.Task
function dapui.async.run(func, cb)
  return tasks.run(func, cb)
end

--- Creates an async function with a callback style function.
--- ```lua
---   local async = require("dapui").async
---   local sleep = async.wrap(function(ms, cb)
---     vim.defer_fn(cb, ms)
---   end, 2)
---
---   async.run(function()
---     sleep(10)
---     print("Slept for 10ms")
---   end)
--- ```
---@param func function A callback style function to be converted. The last argument must be the callback.
---@param argc integer The number of arguments of func. Must be included.
---@return function Returns an async function
function dapui.async.wrap(func, argc)
  return tasks.wrap(func, argc)
end

--- Run a collection of async functions concurrently and return when
--- all have finished.
--- If any of the functions fail, all pending tasks will be cancelled and the
--- error will be re-raised
---@async
---@param functions function[]
---@return any[][] Packed results of all functions
function dapui.async.gather(functions)
  local results = {}

  local done_event = control.event()

  local err
  local running = {}
  for i, func in ipairs(functions) do
    local task = tasks.run(func, function(success, ...)
      if not success then
        err = { ... }
        done_event.set()
      end
      results[#results + 1] = { i = i, success = success, result = { ... } }
      if #results == #functions then
        done_event.set()
      end
    end)
    running[#running + 1] = task
  end
  done_event.wait()
  if err then
    for _, task in ipairs(running) do
      task.cancel()
    end
    error(("%s\n%s"):format(unpack(err)))
  end
  local sorted = {}
  for _, result in ipairs(results) do
    sorted[result.i] = result.result
  end
  return sorted
end

--- Run a collection of async functions concurrently and return the result of
--- the first to finish.
---@async
---@param functions function[]
---@return any
function dapui.async.first(functions)
  local running_tasks = {}
  local event = control.event()
  local failed, result

  for _, func in ipairs(functions) do
    local task = tasks.run(func, function(success, ...)
      if event.is_set() then
        return
      end
      failed = not success
      result = { ... }
      event.set()
    end)
    table.insert(running_tasks, task)
  end
  event.wait()
  for _, task in ipairs(running_tasks) do
    task.cancel()
  end
  if failed then
    error(unpack(result))
  end
  return unpack(result)
end

local async_defer = dapui.async.wrap(function(time, cb)
  assert(cb, "Cannot call sleep from non-async context")
  vim.defer_fn(cb, time)
end, 2)

--- Suspend the current task for given time.
---@param ms number Time in milliseconds
function dapui.async.sleep(ms)
  async_defer(ms)
end

local wrapped_schedule = dapui.async.wrap(vim.schedule, 1)

--- Yields to the Neovim scheduler to be able to call the API.
---@async
function dapui.async.scheduler()
  wrapped_schedule()
end

---@nodoc
local function proxy_vim(prop)
  return setmetatable({}, {
    __index = function(_, k)
      return function(...)
        -- if we are in a fast event await the scheduler
        if vim.in_fast_event() then
          async.scheduler()
        end

        return vim[prop][k](...)
      end
    end,
  })
end

--- Safely proxies calls to the vim.api module while in an async context.
dapui.async.api = proxy_vim("api")
--- Safely proxies calls to the vim.fn module while in an async context.
dapui.async.fn = proxy_vim("fn")
--- Async versions of vim.ui functions

-- For type checking
if false then
  dapui.async.api = vim.api
  dapui.async.fn = vim.fn
end

return dapui.async
