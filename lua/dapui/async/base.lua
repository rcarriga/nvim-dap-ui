local logger = require("dapui.logging")
local dapui = {}

---@toc_entry Async Library
---@text
--- This library was originally taken from https://github.com/lewis6991/async.nvim.
--- The API is heavily inspired by Python's asyncio module
---@class dapui.async
dapui.async = {}

---@type table<thread, dapui.async.Task>
---@nodoc
local tasks = {}

-- Coroutine.running() was changed between Lua 5.1 and 5.2:
-- - 5.1: Returns the running coroutine, or nil when called by the main thread.
-- - 5.2: Returns the running coroutine plus a boolean, true when the running
--   coroutine is the main one.
--
-- For LuaJIT, 5.2 behaviour is enabled with LUAJIT_ENABLE_LUA52COMPAT

---@nodoc
local function current_non_main_co()
  local data = { coroutine.running() }

  if select("#", unpack(data)) == 2 then
    local co, is_main = unpack(data)
    if is_main then
      return nil
    end
    return co
  end

  return unpack(data)
end

---@text
--- Tasks represent a top level running asynchronous function
--- Only one task is ever executing at any time.
---@class dapui.async.Task
---@field cancel fun(): nil Cancels the task
---@field done fun(): boolean Returns true if the task is done
---@field cancelled fun(): boolean Returns true if the task is cancelled
---@field parent? dapui.async.Task Parent task
---@field name fun(): string Get the name of the task
---@field set_name fun(name: string): nil Sets the name of the task
---@field error fun(): dapui.async.TaskError Get the error of the task
---@field result fun(): any Get the result of the task
---@field add_callback fun(cb: fun(task: dapui.async.Task)): nil

---@class dapui.async.TaskError
---@field message string
---@field traceback? string

local TaskError = function(message, traceback)
  return setmetatable({
    message = message,
    traceback = traceback,
  }, {
    __tostring = function()
      return string.format(
        "The coroutine failed with this message: \n%s\nCoroutine %s",
        message,
        traceback
      )
    end,
  })
end

--- Run a function in an async context. This is the entrypoint to all async
--- functionality.
--- >lua
---   local async = require("dapui").async
---   async.run(function()
---     async.sleep(10)
---     print("Hello world")
---   end)
---
--- <
---@param func function
---@return dapui.async.Task
function dapui.async.run(func)
  local co = coroutine.create(func)
  local current_co = current_non_main_co()
  local cancelled = false
  local name = "anonymous"
  local final_result = {}
  local final_err
  local callbacks = {}
  local task = { parent = current_co and tasks[current_co] }

  function task.cancel()
    if coroutine.status(co) == "dead" then
      return
    end
    cancelled = true
  end

  function task.name()
    return name
  end

  function task.set_name(new_name)
    name = new_name
  end

  function task.done()
    return coroutine.status(co) == "dead"
  end

  function task.cancelled()
    return cancelled
  end

  function task.result()
    return unpack(final_result)
  end

  function task.error()
    return final_err
  end

  function task.add_callback(callback)
    if task.done() then
      callback(task)
    else
      callbacks[#callbacks + 1] = callback
    end
  end

  local function run_callbacks()
    for _, cb in ipairs(callbacks) do
      xpcall(cb, function(msg)
        logger.error(("Error in callback for task %s: %s"):format(name, debug.traceback(msg)))
      end, task)
    end
    callbacks = {}
  end

  tasks[co] = task

  local function step(...)
    if cancelled then
      final_err = TaskError("Task was cancelled")
      run_callbacks()
      return
    end

    local ret = { coroutine.resume(co, ...) }
    local success = ret[1]

    if not success then
      final_err = TaskError(ret[2], debug.traceback(co))
      run_callbacks()
      return
    end
    local _, nargs, protected, err_or_fn = unpack(ret)

    if coroutine.status(co) == "dead" then
      final_result = { unpack(ret, 2) }
      run_callbacks()
      return
    end

    assert(
      type(err_or_fn) == "function",
      ("type error :: expected func, got %s"):format(type(err_or_fn))
    )

    local args = { select(5, unpack(ret)) }

    if protected then
      args[nargs] = function(...)
        step(true, ...)
      end
      local ok, err = pcall(err_or_fn, unpack(args, 1, nargs))
      if not ok then
        step(false, err, debug.traceback(co, err, 2))
      end
    else
      args[nargs] = step
      err_or_fn(unpack(args, 1, nargs))
    end
  end

  step()
  return task
end

--- Get the current running task
---@return dapui.async.Task|nil
function dapui.async.current_task()
  local co = current_non_main_co()
  if not co then
    return nil
  end
  return tasks[co]
end

--- Creates an async function with a callback style function.
--- >lua
---   local async = require("dapui").async
---   local sleep = async.wrap(function(ms, cb)
---     vim.defer_fn(cb, ms)
---   end, 2)
---
---   async.run(function()
---     sleep(10)
---     print("Slept for 10ms")
---   end)
--- <
---@param func function A callback style function to be converted. The last argument must be the callback.
---@param argc integer The number of arguments of func. Must be included.
---@param protected boolean? Call the function in protected mode (like pcall), except on error a third value is returned which is the stack trace of where the error occurred.
---@return function Returns an async function
function dapui.async.wrap(func, argc, protected)
  assert(argc, "Must provide argc")
  return function(...)
    if not current_non_main_co() then
      return func(...)
    end
    return coroutine.yield(argc, protected or false, func, ...)
  end
end

--- Run a collection of async functions (`thunks`) concurrently and return when
--- all have finished.
---@param thunks function[]
---@param args? dapui.async.JoinArgs
---@return boolean, any[][]|string Whether all thunks completed or not and packed results of the thunks or error
function dapui.async.join(thunks, args)
  ---@class dapui.async.JoinArgs
  ---@field concurrent? integer Max number of thunks to run concurrently, defaults to no
  --- limit
  ---@field interrupt_check? function Function to abort thunks between calls

  args = args or {}
  local max_concurrent = args.concurrent or #thunks
  local interrupt_check = args.interrupt_check

  ---@nodoc
  local function run(finish)
    if #thunks == 0 then
      return finish(true)
    end
    local errored = false

    local remaining = { select(max_concurrent + 1, unpack(thunks)) }
    local to_go = #thunks

    local ret = {}

    local function cb(task)
      if errored then
        return
      end
      if task.error() then
        errored = true
        finish(false, task.error())
        return
      end
      ret[#ret + 1] = { task.result() }
      to_go = to_go - 1
      if to_go == 0 then
        finish(true, ret)
      elseif not interrupt_check or not interrupt_check() then
        if #remaining > 0 then
          local next_task = table.remove(remaining)
          next_task(cb)
        end
      end
    end

    for i = 1, math.min(max_concurrent, #thunks) do
      local task = dapui.async.run(thunks[i])
      task.add_callback(cb)
    end
  end

  return coroutine.yield(1, false, run)
end

local async_defer = dapui.async.wrap(function(time, cb)
  vim.defer_fn(cb, time)
end, 2)

--- Suspend the current task for given time.
---@param ms number Time in milliseconds
function dapui.async.sleep(ms)
  async_defer(ms)
end

local wrapped_schedule = dapui.async.wrap(vim.schedule, 1, false)

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
dapui.async.ui = {
  ---@type fun(entries: string[], opts: table): string
  ---@nodoc
  select = dapui.async.wrap(vim.ui.select, 3),
  ---@type fun(opts: table): string
  ---@nodoc
  input = dapui.async.wrap(vim.ui.input, 2),
}

-- For type checking
if false then
  dapui.async.api = vim.api
  dapui.async.fn = vim.fn
  dapui.async.control = require("dapui.async.control")
  dapui.async.tests = require("dapui.async.tests")
end

return dapui.async
