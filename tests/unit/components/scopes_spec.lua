local Scopes = require("dapui.components.scopes")
local render = require("dapui.render")

describe("checking scopes", function()
  require("dapui.config").setup({})
  assert:add_formatter(vim.inspect)

  local mock_state
  before_each(function()
    mock_state = {
      on_clear = function() end,
      current_frame = function()
        return { id = 1 }
      end,
      scopes = function()
        return {
          {
            name = "Scope A",
            variablesReference = 1,
          },
          {
            name = "Scope B",
            variablesReference = 2,
          },
        }
      end,
      step_number = function()
        return 1
      end,
      variables = function(_, ref)
        if ref == 1 then
          return {
            {
              evaluateName = "a",
              name = "a",
              type = "int",
              value = "1",
              variablesReference = 3,
            },
            {
              evaluateName = "b",
              name = "b",
              type = "dict",
              value = "{}",
              variablesReference = 4,
            },
          }
        end
        if ref == 2 then
          return {
            {
              evaluateName = "c",
              name = "c",
              type = "list",
              value = "[2, 3, 4, 10]",
              variablesReference = 5,
            },
          }
        end
        assert(false, "Invalid variable reference passed")
      end,
    }
  end)

  it("creates lines", function()
    local canvas = render.new_canvas()
    local component = Scopes(mock_state)

    component:render(canvas)
    local expected = {
      "Scope A:",
      " ▸ a int = 1",
      " ▸ b dict = {}",
      "",
      "Scope B:",
      " ▸ c list = [2, 3, 4, 10]",
    }
    assert.are.same(expected, canvas.lines)
  end)

  it("creates matches", function()
    local canvas = render.new_canvas()
    local component = Scopes(mock_state)

    component:render(canvas)
    local expected = {
      { "DapUIScope", { 1, 1, 7 } },
      { "DapUIDecoration", { 2, 2, 3 } },
      { "DapUIVariable", { 2, 6, 1 } },
      { "DapUIType", { 2, 8, 3 } },
      { "DapUIValue", { 2, 14, 1 } },
      { "DapUIDecoration", { 3, 2, 3 } },
      { "DapUIVariable", { 3, 6, 1 } },
      { "DapUIType", { 3, 8, 4 } },
      { "DapUIValue", { 3, 15, 2 } },
      { "DapUIScope", { 5, 1, 7 } },
      { "DapUIDecoration", { 6, 2, 3 } },
      { "DapUIVariable", { 6, 6, 1 } },
      { "DapUIType", { 6, 8, 4 } },
      { "DapUIValue", { 6, 15, 13 } },
    }
    assert.are.same(expected, canvas.matches)
  end)

  it("creates expand mappings", function()
    local canvas = render.new_canvas()
    local component = Scopes(mock_state)

    component:render(canvas)
    assert.equal(3, #canvas.mappings["expand"])
  end)

  describe("when variables are not found", function()
    local monitored
    local invalid_state
    before_each(function()
      monitored = {}
      invalid_state = {
        current_frame = function()
          return { id = 1 }
        end,
        scopes = function()
          return {
            {
              name = "Scope A",
              variablesReference = 1,
            },
            {
              name = "Scope B",
              variablesReference = 2,
            },
          }
        end,
        variables = function()
          return nil
        end,
        monitor = function(_, ref)
          monitored[ref] = true
        end,
        step_number = function()
          return 1
        end,
      }
    end)

    it("renders empty scopes", function()
      local canvas = render.new_canvas()
      local component = Scopes(invalid_state)

      component:render(canvas)
      local expected = { "Scope A:", "", "Scope B:" }
      assert.are.same(expected, canvas.lines)
    end)
  end)
end)
