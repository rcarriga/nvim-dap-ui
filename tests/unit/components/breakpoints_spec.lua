local mock = require("luassert.mock")

local Breakpoints = require("dapui.components.breakpoints")
local render = require("dapui.render")

describe("checking multiple file breakpoints", function()
  assert:add_formatter(vim.inspect)
  require("dapui.config").setup({})
  local buf_a = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_buf_set_name(buf_a, "test/file_a.py")
  local buf_b = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_buf_set_name(buf_b, "test/file_b.py")
  local breakpoints = {
    [buf_b] = { { line = 25, file = "test/file_b.py", enabled = true } },
    [buf_a] = {
      { line = 10, file = "test/file_a.py", enabled = true },
      { line = 20, file = "test/file_a.py", enabled = true },
    },
  }

  local mock_state = {
    breakpoints = function()
      return breakpoints
    end,
    current_frame = function()
      return { source = { path = "test/file_a.py" }, line = 20 }
    end,
  }

  local api = mock(vim.api, true)
  api.nvim_buf_get_lines.returns({ "text" })

  it("creates lines", function()
    local canvas = render.new_canvas()
    local component = Breakpoints(mock_state)

    component:render(canvas)
    local expected = {
      "file_a.py:",
      " 10 text",
      " 20 text",
      "",
      "file_b.py:",
      " 25 text",
    }
    assert.are.same(expected, canvas.lines)
  end)

  it("creates matches", function()
    local canvas = render.new_canvas()
    local component = Breakpoints(mock_state)

    component:render(canvas)

    local expected = {
      { "DapUIBreakpointsPath", { 1, 1, 9 } },
      { "DapUIBreakpointsLine", { 2, 2, 2 } },
      { "DapUIBreakpointsCurrentLine", { 3, 2, 2 } },
      { "DapUIBreakpointsPath", { 5, 1, 9 } },
      { "DapUIBreakpointsLine", { 6, 2, 2 } },
    }
    assert.are.same(expected, canvas.matches)
  end)

  vim.api.nvim_buf_delete(buf_a)
  vim.api.nvim_buf_delete(buf_b)
end)

describe("checking no breakpoints", function()
  require("dapui.config").setup({})

  local mock_state = {
    breakpoints = function()
      return {}
    end,
    current_frame = function()
      return { source = { path = "test/file_a.py" }, line = 20 }
    end,
  }

  local api = mock(vim.api, true)
  api.nvim_buf_get_lines.returns({ "text" })

  it("creates single empty line", function()
    local canvas = render.new_canvas()
    local component = Breakpoints(mock_state)

    component:render(canvas)
    local expected = {
      "",
    }
    assert.are.same(expected, canvas.lines)
  end)
end)
