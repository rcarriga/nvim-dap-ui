local Threads = require("dapui.components.threads")
local render = require("dapui.render")

describe("checking threads", function()
  require("dapui.config").setup({})
  assert:add_formatter(vim.inspect)

  local mock_state = {
    threads = function()
      return { { id = 1, name = "Thread 1" }, { id = 2, name = "Thread 2" } }
    end,
    stopped_thread = function()
      return { id = 1, name = "Thread 1" }
    end,
    frames = function(_, id)
      if id == 1 then
        return {
          {
            column = 0,
            id = 1000,
            line = 6,
            name = "test_1",
            source = {
              name = "test_a.py",
              path = "/test/test_a.py",
              sourceReference = 0,
            },
          },
          {
            column = 0,
            id = 1001,
            line = 1193,
            name = "test_2",
            source = {
              name = "test_b.py",
              path = "/test/test_b.py",
              sourceReference = 0,
            },
          },
          {
            column = 0,
            id = 1001,
            line = 200,
            name = "test_3",
            presentationHint = "subtle",
            source = {
              name = "test_c.py",
              path = "/test/test_c.py",
              sourceReference = 0,
            },
          },
        }
      end
      if id == 2 then
        return {
          {
            column = 0,
            id = 1002,
            line = 1371,
            name = "test_3",
            source = {
              name = "test_c.py",
              path = "/test/test_c.py",
              sourceReference = 0,
            },
          },
        }
      end
      assert(false, "Invalid thread ID passed")
    end,
  }

  it("creates lines", function()
    local canvas = render.new_canvas()
    local component = Threads(mock_state)

    component:render(canvas, 0)
    local expected = {
      "Thread 1:",
      " test_1 test_a.py:6",
      " test_2 test_b.py:1193",
      "",
      "Thread 2:",
      " test_3 test_c.py:1371",
    }
    assert.are.same(expected, canvas.lines)
  end)

  it("creates matches", function()
    local canvas = render.new_canvas()
    local component = Threads(mock_state)

    component:render(canvas)
    local expected = {
      { "DapUIStoppedThread", { 1, 1, 8 } },
      { "DapUIFrameName", { 2, 2, 6 } },
      { "DapUISource", { 2, 9, 9 } },
      { "DapUILineNumber", { 2, 19, 1 } },
      { "DapUIFrameName", { 3, 2, 6 } },
      { "DapUISource", { 3, 9, 9 } },
      { "DapUILineNumber", { 3, 19, 4 } },
      { "DapUIThread", { 5, 1, 8 } },
      { "DapUIFrameName", { 6, 2, 6 } },
      { "DapUISource", { 6, 9, 9 } },
      { "DapUILineNumber", { 6, 19, 4 } },
    }
    assert.are.same(expected, canvas.matches)
  end)

  it("creates open mappings", function()
    local canvas = render.new_canvas()
    local component = Threads(mock_state)

    component:render(canvas)
    assert.equal(3, #canvas.mappings["open"])
  end)

  it("creates toggle mappings", function()
    local canvas = render.new_canvas()
    local component = Threads(mock_state)

    component:render(canvas)
    assert.equal(3, #canvas.mappings["open"])
  end)

  describe("with subtle frames", function()
    local component
    before_each(function()
      component = Threads(mock_state)
      local canvas = render.new_canvas()
      component:render(canvas, 0)
      canvas.mappings["toggle"][1][1]()
    end)

    it("creates lines", function()
      local canvas = render.new_canvas()

      component:render(canvas, 0)
      local expected = {
        "Thread 1:",
        " test_1 test_a.py:6",
        " test_2 test_b.py:1193",
        " test_3 test_c.py:200",
        "",
        "Thread 2:",
        " test_3 test_c.py:1371",
      }
      assert.are.same(expected, canvas.lines)
    end)

    it("creates matches", function()
      local canvas = render.new_canvas()

      component:render(canvas)
      local expected = {
        { "DapUIStoppedThread", { 1, 1, 8 } },
        { "DapUIFrameName", { 2, 2, 6 } },
        { "DapUISource", { 2, 9, 9 } },
        { "DapUILineNumber", { 2, 19, 1 } },
        { "DapUIFrameName", { 3, 2, 6 } },
        { "DapUISource", { 3, 9, 9 } },
        { "DapUILineNumber", { 3, 19, 4 } },
        { "DapUIFrameName", { 4, 2, 6 } },
        { "DapUISource", { 4, 9, 9 } },
        { "DapUILineNumber", { 4, 19, 3 } },
        { "DapUIThread", { 6, 1, 8 } },
        { "DapUIFrameName", { 7, 2, 6 } },
        { "DapUISource", { 7, 9, 9 } },
        { "DapUILineNumber", { 7, 19, 4 } },
      }

      assert.are.same(expected, canvas.matches)
    end)

    it("creates open mappings", function()
      local canvas = render.new_canvas()

      component:render(canvas)
      assert.equal(4, #canvas.mappings["open"])
    end)

    it("creates toggle mappings", function()
      local canvas = render.new_canvas()

      component:render(canvas)
      assert.equal(4, #canvas.mappings["open"])
    end)
  end)
end)
