local mock = require("luassert.mock")
local stub = require("luassert.stub")

local BufBreakpoint = require("dapui.components.buf_breakpoints")
local render = require("dapui.render")

describe("checking simple breakpoints", function()
  local breakpoints = {
    { line = 10, file = "test/file.py" },
    { line = 20, file = "test/file.py" },
    { line = 25, file = "test/file.py" },
  }
  local api = mock(vim.api, true)
  api.nvim_buf_get_lines.returns({ "text" })

  it("creates lines", function()
    local render_state = render.new_state()
    local component = BufBreakpoint()

    component:render(render_state, 1, breakpoints, 20, "test/file.py", 0)
    local expected = { "10 text", "20 text", "25 text" }
    assert.are.same(expected, render_state.lines)
  end)

  it("creates matches", function()
    local render_state = render.new_state()
    local component = BufBreakpoint()

    component:render(render_state, 1, breakpoints, 20, "test/file.py", 0)
    local expected = {
      { "DapUIBreakpointsLine", { 1, 1, 2 } },
      { "DapUIBreakpointsCurrentLine", { 2, 1, 2 } },
      { "DapUIBreakpointsLine", { 3, 1, 2 } },
    }
    assert.are.same(expected, render_state.matches)
  end)

  it("creates mappings", function()
    local render_state = render.new_state()
    local component = BufBreakpoint()

    component:render(render_state, 1, breakpoints, 20, "test/file.py", 0)
    assert.equal(3, #render_state.mappings["open"])
  end)

  it("mappings open frame", function()
    local util = require("dapui.util")
    stub(util, "jump_to_frame")
    local render_state = render.new_state()
    local component = BufBreakpoint()

    component:render(render_state, 1, breakpoints, 20, "test/file.py", 0)

    render_state.mappings["open"][1][1]()

    assert.stub(util.jump_to_frame).was.called_with({
      line = 10,
      column = 0,
      source = { path = "test/file.py" },
    })

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
    local render_state = render.new_state()
    local component = BufBreakpoint()

    component:render(render_state, 1, breakpoints, 20, "test/file.py", 0)
    local expected = {
      "10 text",
      "   Log Message: Message",
      "20 text",
      "   Condition: Condition",
      "25 text",
      "   Hit Condition: HitCondition",
    }
    assert.are.same(expected, render_state.lines)
  end)

  mock.revert(api)
end)
