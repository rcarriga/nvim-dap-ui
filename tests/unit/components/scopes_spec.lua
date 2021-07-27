local Scopes = require("dapui.components.scopes")
local render = require("dapui.render")

describe("checking scopes", function()
  require("dapui.config").setup({})

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
    local render_state = render.new_state()
    local component = Scopes(mock_state)

    component:render(render_state)
    local expected = {
      "Scope A:",
      " ▸ a int = 1",
      " ▸ b dict = {}",
      "",
      "Scope B:",
      " ▸ c list = [2, 3, 4, 10]",
    }
    assert.are.same(expected, render_state.lines)
  end)

  it("creates matches", function()
    local render_state = render.new_state()
    local component = Scopes(mock_state)

    component:render(render_state)
    local expected = {
      { "DapUIScope", { 1, 1, 7 } },
      { "DapUIDecoration", { 2, 2, 1 } },
      { "DapUIVariable", { 2, 6, 1 } },
      { "DapUIType", { 2, 8, 3 } },
      { "DapUIDecoration", { 3, 2, 1 } },
      { "DapUIVariable", { 3, 6, 1 } },
      { "DapUIType", { 3, 8, 4 } },
      { "DapUIScope", { 5, 1, 7 } },
      { "DapUIDecoration", { 6, 2, 1 } },
      { "DapUIVariable", { 6, 6, 1 } },
      { "DapUIType", { 6, 8, 4 } },
    }
    assert.are.same(expected, render_state.matches)
  end)

  it("creates expand mappings", function()
    local render_state = render.new_state()
    local component = Scopes(mock_state)

    component:render(render_state)
    assert.equal(3, #render_state.mappings["expand"])
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
      }
    end)

    it("invalidates render", function()
      local render_state = render.new_state()
      local component = Scopes(invalid_state)

      component:render(render_state)
      assert.False(render_state.valid)
    end)
  end)
end)
