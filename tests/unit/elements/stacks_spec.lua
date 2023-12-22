local nio = require("nio")
local a = nio.tests
local Stacks = require("dapui.elements.stacks")
local tests = require("dapui.tests")
tests.bootstrap()
local mocks = tests.mocks

describe("stacks element", function()
  local client, stacks, buf
  a.before_each(function()
    client = mocks.client({
      current_frame = {
        id = 1,
      },
      requests = {
        scopes = mocks.scopes({
          scopes = {
            [1] = {
              {
                name = "Locals",
                variablesReference = 1,
              },
              {
                name = "Globals",
                variablesReference = 2,
              },
            },
          },
        }),
        threads = mocks.threads({
          threads = {
            {
              id = 1,
              name = "Thread 1",
            },
            {
              id = 2,
              name = "Thread 2",
            },
          },
        }),
        stackTrace = mocks.stack_traces({
          stack_traces = {
            [1] = {
              {
                id = 1,
                name = "stack_frame_1",
                source = {
                  name = "file_1",
                },
                line = 1,
              },
              {
                id = 2,
                name = "stack_frame_2",
                source = {
                  name = "file_2",
                },
                line = 2,
                presentationHint = "subtle",
              },
            },
            [2] = {
              {
                id = 3,
                name = "stack_frame_3",
                source = {
                  name = "file_3",
                },
                line = 3,
              },
              {
                id = 4,
                name = "stack_frame_4",
                source = {
                  name = "file_4",
                },
                line = 4,
              },
            },
          },
        }),
      },
    })
    stacks = Stacks(client)
    client.request.threads()
    client.request.scopes({ frameId = 1 })
    buf = stacks.buffer()
    nio.sleep(10)
  end)
  after_each(function()
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
    stacks = nil
    client.shutdown()
  end)
  a.it("renders initial lines", function()
    stacks.render()
    local lines = nio.api.nvim_buf_get_lines(buf, 0, -1, false)
    assert.same({
      "Thread 1:",
      " stack_frame_1 file_1:1",
      "",
      "Thread 2:",
      " stack_frame_3 file_3:3",
      " stack_frame_4 file_4:4",
      "",
      "",
    }, lines)
  end)

  a.it("renders initial highlights", function()
    stacks.render()
    local formatted = tests.util.get_highlights(buf)
    assert.same({
      { "DapUIThread", 0, 0, 0, 8 },
      { "DapUICurrentFrameName", 1, 4, 1, 17 },
      { "DapUISource", 1, 18, 1, 24 },
      { "DapUILineNumber", 1, 25, 1, 26 },
      { "DapUIThread", 3, 0, 3, 8 },
      { "DapUIFrameName", 4, 1, 4, 14 },
      { "DapUISource", 4, 15, 4, 21 },
      { "DapUILineNumber", 4, 22, 4, 23 },
      { "DapUIFrameName", 5, 1, 5, 14 },
      { "DapUISource", 5, 15, 5, 21 },
      { "DapUILineNumber", 5, 22, 5, 23 },
    }, formatted)
  end)

  describe("with subtle frames shown", function()
    a.it("renders expanded lines", function()
      stacks.render()
      local keymaps = tests.util.get_mappings(stacks.buffer())
      keymaps["t"](1)
      nio.sleep(10)
      local lines = nio.api.nvim_buf_get_lines(buf, 0, -1, false)
      assert.same({
        "Thread 1:",
        " stack_frame_1 file_1:1",
        " stack_frame_2 file_2:2",
        "",
        "Thread 2:",
        " stack_frame_3 file_3:3",
        " stack_frame_4 file_4:4",
        "",
        "",
      }, lines)
    end)
    a.it("renders expanded highlights", function()
      stacks.render()
      local keymaps = tests.util.get_mappings(stacks.buffer())
      keymaps["t"](1)
      stacks.render()
      local formatted = tests.util.get_highlights(buf)
      assert.same({
        { "DapUIThread", 0, 0, 0, 8 },
        { "DapUICurrentFrameName", 1, 4, 1, 17 },
        { "DapUISource", 1, 18, 1, 24 },
        { "DapUILineNumber", 1, 25, 1, 26 },
        { "DapUIFrameName", 2, 1, 2, 14 },
        { "DapUISource", 2, 15, 2, 21 },
        { "DapUILineNumber", 2, 22, 2, 23 },
        { "DapUIThread", 4, 0, 4, 8 },
        { "DapUIFrameName", 5, 1, 5, 14 },
        { "DapUISource", 5, 15, 5, 21 },
        { "DapUILineNumber", 5, 22, 5, 23 },
        { "DapUIFrameName", 6, 1, 6, 14 },
        { "DapUISource", 6, 15, 6, 21 },
        { "DapUILineNumber", 6, 22, 6, 23 },
      }, formatted)
    end)
  end)
end)
