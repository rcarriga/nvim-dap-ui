local tasks = require("dapui.async.tasks")
local async = require("dapui.async")
local a = async.tests
local tests = require("dapui.tests")
tests.bootstrap()

describe("task", function()
  a.it("provides result in callback", function()
    local result
    tasks.run(function()
      async.sleep(5)
      return "test"
    end, function(_, result_)
      result = result_
    end)
    async.sleep(10)
    assert.equals("test", result)
  end)

  a.it("cancels", function()
    local err
    local task = tasks.run(function()
      async.sleep(10)
      return "test"
    end, function(_, err_)
      err = err_
    end)
    task.cancel()
    async.sleep(10)
    assert.True(vim.endswith(vim.split(err, "\n")[1], "Task was cancelled"))
  end)

  a.it("cancels children", function()
    local should_be_nil
    local task = tasks.run(function()
      tasks.run(function()
        async.sleep(10)
        should_be_nil = "not nil"
      end)
      async.sleep(10)
    end)
    task.cancel()
    async.sleep(20)
    assert.Nil(should_be_nil)
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
    local success, err
    tasks.run(function()
      error("test")
    end, function(success_, err_)
      success, err = success_, err_
    end)
    async.sleep(10)
    assert.False(success)
    assert.True(vim.endswith(vim.split(err, "\n")[2], "test"))
  end)

  a.it("returns error when wrapped function errors", function()
    local success, err
    local bad_wrapped = tasks.wrap(function()
      error("test")
    end, 1)
    tasks.run(bad_wrapped, function(success_, err_)
      success, err = success_, err_
    end)
    async.sleep(10)
    assert.False(success)
    assert.True(vim.endswith(vim.split(err, "\n")[2], "test"))
  end)

  a.it("pcall returns result", function()
    local success, x, y = pcall(function()
      return 1, 2
    end)
    assert.True(success)
    assert.equals(1, x)
    assert.equals(2, y)
  end)

  a.it("pcall returns error", function()
    local success, err = pcall(function()
      error("test")
    end)
    assert.False(success)
    assert.True(vim.endswith(vim.split(err, "\n")[1], "test"))
  end)

  a.it("pcall returns error when wrapped function errors", function()
    local success, err = pcall(tasks.wrap(function(...)
      error("test")
    end, 1))

    async.sleep(10)
    assert.False(success)
    assert.True(vim.endswith(vim.split(err, "\n")[1], "test"))
  end)

  a.it("current task", function()
    local current
    local task = tasks.run(function()
      current = tasks.current_task()
    end)
    assert.equal(task, current)
  end)
end)
