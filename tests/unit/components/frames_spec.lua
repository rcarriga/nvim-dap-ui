local stub = require("luassert.stub")

local StackFrames = require("dapui.components.frames")
local render = require("dapui.render")

describe("checking stack frames", function()
  local frames = {
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

  it("creates lines", function()
    local canvas = render.new_canvas()
    local component = StackFrames()

    component:render(canvas, frames, 1)
    local expected = {
      " test_1 test_a.py:6",
      " test_2 test_b.py:1193",
      " test_3 test_c.py:1371",
    }
    assert.are.same(expected, canvas.lines)
  end)

  it("creates matches", function()
    local canvas = render.new_canvas()
    local component = StackFrames()

    component:render(canvas, frames, 1)
    local expected = {
      { "DapUIFrameName", { 1, 2, 6 } },
      { "DapUISource", { 1, 9, 9 } },
      { "DapUILineNumber", { 1, 19, 1 } },
      { "DapUIFrameName", { 2, 2, 6 } },
      { "DapUISource", { 2, 9, 9 } },
      { "DapUILineNumber", { 2, 19, 4 } },
      { "DapUIFrameName", { 3, 2, 6 } },
      { "DapUISource", { 3, 9, 9 } },
      { "DapUILineNumber", { 3, 19, 4 } },
    }
    assert.are.same(expected, canvas.matches)
  end)

  it("creates mappings", function()
    local canvas = render.new_canvas()
    local component = StackFrames()

    component:render(canvas, frames, 1)
    assert.equal(3, #canvas.mappings["open"])
  end)

  it("mappings open frame", function()
    local util = require("dapui.util")
    package.loaded["dap"] = {
      session = function()
        return { 1 }
      end,
    }
    stub(util, "jump_to_frame")
    local canvas = render.new_canvas()
    local component = StackFrames()

    component:render(canvas, frames, 1)

    canvas.mappings["open"][1][1]()

    assert.stub(util.jump_to_frame).was.called_with({
      column = 0,
      id = 1000,
      line = 6,
      name = "test_1",
      source = {
        name = "test_a.py",
        path = "/test/test_a.py",
        sourceReference = 0,
      },
    }, {
      1,
    }, true)
  end)
end)
