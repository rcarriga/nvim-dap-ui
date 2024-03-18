local nio = require("nio")
local Breakpoints = require("dapui.elements.breakpoints")
local a = nio.tests
local tests = require("dapui.tests")
tests.bootstrap()
local mocks = tests.mocks

describe("breakpoints element", function()
  local client, breakpoints, buf
  local init_bps = {
    test_a = {
      lines = {
        "line_a_1",
        "line_a_2",
        "line_a_3",
      },
      bps = {
        [1] = {},
        [3] = { condition = "a + 3 == 3" },
      },
    },
    test_b = {
      lines = {
        "line_b_1",
        "line_b_2",
        "line_b_3",
      },
      bps = {
        [2] = { log_message = "here" },
      },
    },
  }
  a.before_each(function()
    client = mocks.client({
      current_frame = {
        id = 1,
        line = 1,
        source = {
          path = "test_a",
        },
      },
    })
    for path, data in pairs(init_bps) do
      local path_buf = vim.api.nvim_create_buf(true, true)
      nio.api.nvim_buf_set_name(path_buf, path)
      nio.api.nvim_buf_set_lines(path_buf, 0, -1, false, data.lines)
      for line, bp in pairs(data.bps) do
        client.breakpoints.toggle(path_buf, line, bp)
      end
    end
    breakpoints = Breakpoints(client)
    breakpoints.render()
    buf = breakpoints.buffer()
  end)

  after_each(function()
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
    for path, _ in pairs(init_bps) do
      local path_buf = vim.fn.bufnr(path)
      pcall(vim.api.nvim_buf_delete, path_buf, { force = true })
    end
    breakpoints = nil
  end)

  a.it("renders lines", function()
    local lines = nio.api.nvim_buf_get_lines(buf, 0, -1, false)
    assert.same({
      "test_a:",
      " 1 line_a_1",
      " 3 line_a_3",
      "   Condition: a + 3 == 3",
      "",
      "test_b:",
      " 2 line_b_2",
      "   Log Message: here",
    }, lines)
  end)

  a.it("renders highlights", function()
    local highlights = tests.util.get_highlights(buf)
    assert.same({
      { "DapUIBreakpointsPath", 0, 0, 0, 6 },
      { "DapUIBreakpointsCurrentLine", 1, 1, 1, 2 },
      { "DapUIBreakpointsLine", 2, 1, 2, 2 },
      { "DapUIBreakpointsInfo", 3, 3, 3, 13 },
      { "DapUIBreakpointsPath", 5, 0, 5, 6 },
      { "DapUIBreakpointsLine", 6, 1, 6, 2 },
      { "DapUIBreakpointsInfo", 7, 3, 7, 15 },
    }, highlights)
  end)

  a.it("renders highlights with toggled breakpoint", function()
    local keymaps = tests.util.get_mappings(buf)
    keymaps.t(3)
    local highlights = tests.util.get_highlights(buf)
    assert.same({
      { "DapUIBreakpointsPath", 0, 0, 0, 6 },
      { "DapUIBreakpointsCurrentLine", 1, 1, 1, 2 },
      { "DapUIBreakpointsDisabledLine", 2, 1, 2, 2 },
      { "DapUIBreakpointsInfo", 3, 3, 3, 13 },
      { "DapUIBreakpointsPath", 5, 0, 5, 6 },
      { "DapUIBreakpointsLine", 6, 1, 6, 2 },
      { "DapUIBreakpointsInfo", 7, 3, 7, 15 },
    }, highlights)
  end)
end)
