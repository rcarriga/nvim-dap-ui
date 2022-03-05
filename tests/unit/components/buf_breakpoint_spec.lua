local mock = require("luassert.mock")
local stub = require("luassert.stub")

local BufBreakpoint = require("dapui.components.buf_breakpoints")
local render = require("dapui.render")

describe("checking simple breakpoints", function()
  local breakpoints, disabled, api, mock_state, component
  before_each(function()
    breakpoints = {
      { line = 10, file = "test/file.py", enabled = true },
      { line = 20, file = "test/file.py", enabled = true },
      { line = 25, file = "test/file.py", enabled = true },
    }
    disabled = nil
    api = mock(vim.api, true)
    api.nvim_buf_get_lines.returns({ "text" })

    mock_state = {
      toggle_breakpoint = function(_, bp)
        disabled = bp
      end,
    }
    component = BufBreakpoint(mock_state)
  end)

  it("creates lines", function()
    local canvas = render.new_canvas()

    component:render(canvas, 1, breakpoints, 20, "test/file.py", 0)
    local expected = { "10 text", "20 text", "25 text" }
    assert.are.same(expected, canvas.lines)
  end)

  it("creates matches", function()
    local canvas = render.new_canvas()
    breakpoints[3].enabled = false

    component:render(canvas, 1, breakpoints, 20, "test/file.py", 0)
    local expected = {
      { "DapUIBreakpointsLine", { 1, 1, 2 } },
      { "DapUIBreakpointsCurrentLine", { 2, 1, 2 } },
      { "DapUIBreakpointsDisabledLine", { 3, 1, 2 } },
    }
    assert.are.same(expected, canvas.matches)
  end)

  it("creates mappings", function()
    local canvas = render.new_canvas()

    component:render(canvas, 1, breakpoints, 20, "test/file.py", 0)
    assert.equal(3, #canvas.mappings["open"])
    assert.equal(3, #canvas.mappings["toggle"])
  end)

  it("mappings open frame", function()
    local util = require("dapui.util")
    stub(util, "jump_to_frame")
    local canvas = render.new_canvas()

    component:render(canvas, 1, breakpoints, 20, "test/file.py", 0)

    canvas.mappings["open"][1][1]()

    assert.stub(util.jump_to_frame).was.called_with({
      line = 10,
      column = 0,
      source = { path = "test/file.py" },
    })

    mock.revert(api)
  end)
  it("mapping toggles breakpoint", function()
    local canvas = render.new_canvas()

    component:render(canvas, 1, breakpoints, 20, "test/file.py", 0)

    canvas.mappings["toggle"][1][1]()

    assert.are.same(breakpoints[1], disabled)

    mock.revert(api)
  end)
end)

describe("checking breakpoints with extra metadata", function()
  local breakpoints = {
    { line = 10, file = "test/file.py", logMessage = "Message" },
    { line = 20, file = "test/file.py", condition = "Condition" },
    { line = 25, file = "test/file.py", hitCondition = "HitCondition" },
  }

  local api = mock(vim.api, true)
  api.nvim_buf_get_lines.returns({ "text" })

  it("creates lines", function()
    local canvas = render.new_canvas()
    local component = BufBreakpoint()

    component:render(canvas, 1, breakpoints, 20, "test/file.py", 0)
    local expected = {
      "10 text",
      "   Log Message: Message",
      "20 text",
      "   Condition: Condition",
      "25 text",
      "   Hit Condition: HitCondition",
    }
    assert.are.same(expected, canvas.lines)
  end)

  mock.revert(api)
end)
