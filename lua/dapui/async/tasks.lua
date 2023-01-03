local logger = require("dapui.logging")
local dapui = { async = {} }

---@class dapui.async.tasks
dapui.async.tasks = {}

---@type table<thread, dapui.async.tasks.Task>
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
---@class dapui.async.tasks.Task
---@field cancel fun(): nil Cancels the task
---@field done fun(): boolean Returns true if the task is done
---@field cancelled fun(): boolean Returns true if the task is cancelled
---@field parent? dapui.async.tasks.Task Parent task
---@field name fun(): string Get the name of the task
---@field set_name fun(name: string): nil Sets the name of the task
---@field error fun(): dapui.async.tasks.TaskError Get the error of the task
---@field result fun(): any Get the result of the task
---@field add_callback fun(cb: fun(task: dapui.async.tasks.Task)): nil
---@field trace fun(): string Get the stack trace of the task

---@class dapui.async.tasks.TaskError
---@field message string
---@field traceback? string

local TaskError = function(message, traceback)
  return setmetatable({
    message = message,
    traceback = traceback,
  }, {
    __tostring = function()
      if type(message) ~= "string" then
        message = tostring(message)
      end
      return string.format(
        "The coroutine failed with this message: %s\n%s",
        vim.startswith(traceback, message) and "" or ("\n" .. message),
        traceback
      )
    end,
  })
end

local name_counter = (function()
  local count = 0
  return function()
    count = count + 1
    return count
  end
end)()

---@nodoc
function dapui.async.tasks.run(func)
  local co = coroutine.create(func)
  local cancelled = false
  local name = "Task " .. name_counter()
  local final_result = {}
  local final_err
  local callbacks = {}
  local task = { parent = dapui.async.tasks.current_task() }
  local done

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
    return done
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

  function task.trace()
    return debug.traceback(co)
  end

  function task.add_callback(callback)
    if task.done() then
      callback(task)
    else
      callbacks[#callbacks + 1] = callback
    end
  end

  local function close_task(result, err)
    final_result = result or {}
    final_err = err
    done = true
    tasks[co] = nil
    for _, cb in ipairs(callbacks) do
      xpcall(cb, function(msg)
        logger.error(("Error in callback for task %s: %s"):format(name, debug.traceback(msg)))
      end, task)
    end
  end

  tasks[co] = task

  local function step(...)
    if cancelled then
      close_task(nil, TaskError("Task was cancelled"))
      return
    end

    local ret = { coroutine.resume(co, ...) }
    local success = ret[1]

    if not success then
      close_task(nil, TaskError(ret[2], debug.traceback(co)))
      return
    end

    if coroutine.status(co) == "dead" then
      local result = {}
      for i, v in pairs(ret) do
        result[i - 1] = v
      end
      close_task(result)
      return
    end

    local _, nargs, protected, err_or_fn = unpack(ret)

    assert(
      type(err_or_fn) == "function",
      ("type error :: expected func, got %s"):format(type(err_or_fn))
    )

    local args = { select(5, unpack(ret)) }

    args[nargs] = protected and function(...)
      step(true, ...)
    end or step

    local ok, err = pcall(err_or_fn, unpack(args, 1, nargs))

    if ok then
      return
    end

    if protected then
      step(false, err, debug.traceback(co, err))
      return
    end

    -- We are leaving the coroutine alive here.
    -- GC should take care of it.
    close_task(nil, TaskError(err, debug.traceback(co, err)))
  end

  step()
  return task
end

--- Get the current running task
---@return dapui.async.tasks.Task|nil
function dapui.async.tasks.current_task()
  local co = current_non_main_co()
  if not co then
    return nil
  end
  return tasks[co]
end

---@nodoc
function dapui.async.tasks.wrap(func, argc, protected)
  assert(argc, "Must provide argc")
  return function(...)
    if not current_non_main_co() then
      return func(...)
    end
    return coroutine.yield(argc, protected or false, func, ...)
  end
end

return dapui.async.tasks
