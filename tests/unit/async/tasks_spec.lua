local tasks = require("dapui.async.tasks")
local async = require("dapui.async")
local a = async.tests
local tests = require("dapui.tests")
tests.bootstrap()

describe("task", function()
  a.it("provides result in callbacks when already complete", function()
    local task = tasks.run(function()
      return "test"
    end)
    local result
    async.sleep(10)
    task.add_callback(function()
      result = task.result()
    end)
    assert.equals("test", result)
  end)

  a.it("provides result in callbacks", function()
    local task = tasks.run(function()
      async.sleep(5)
      return "test"
    end)
    local result
    task.add_callback(function()
      result = task.result()
    end)
    async.sleep(10)
    assert.equals("test", result)
  end)

  a.it("cancels", function()
    local task = tasks.run(function()
      async.sleep(10)
      return "test"
    end)
    task.cancel()
    async.sleep(10)
    assert.True(task.cancelled())
    assert.same("Task was cancelled", task.error().message)
    assert.Nil(task.result())
  end)

  a.it("returns result if cancelled when completed", function()
    local task = tasks.run(function()
      return "test"
    end)
    async.sleep(10)
    task.cancel()
    assert.False(task.cancelled())
    assert.Nil(task.error())
    assert.same("test", task.result())
  end)

  a.it("assigns parent task", function()
    local current = tasks.current_task()
    local task = tasks.run(function()
      return "test"
    end)
    assert.Not.Nil(task.parent)
    assert.equal(current, task.parent)
  end)
  it("assigns no parent task", function()
    local task = tasks.run(function()
      return "test"
    end)
    assert.Nil(task.parent)
  end)

  a.it("returns error in function", function()
    local task = tasks.run(function()
      error("test")
    end)
    async.sleep(10)
    assert.True(task.done())
    assert.False(task.cancelled())
    assert.True(vim.endswith(task.error().message, "test"))
    assert.Nil(task.result())
  end)

  a.it("sets error when callback errors", function()
    local bad_wrapped = tasks.wrap(function()
      error("test")
    end, 1)
    local task = tasks.run(bad_wrapped)
    assert.True(task.done())
    assert.True(vim.endswith(task.error().message, "test"))
  end)

  a.it("sets name on creation", function()
    local task1 = tasks.run(function()
      return "test"
    end)
    local task2 = tasks.run(function()
      return "test"
    end)
    assert.matches("Task %d+", task1.name())
    assert.matches("Task %d+", task2.name())
  end)

  a.it("current task", function()
    local current
    local task = tasks.run(function()
      current = tasks.current_task()
    end)
    assert.equal(task, current)
  end)
end)
