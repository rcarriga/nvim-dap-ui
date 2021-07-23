local Hover = require("dapui.components.hover")
local render = require("dapui.render")

describe("checking hover", function()
  require("dapui.config").setup({})

  local expression = "expr"
  local bad_expr = "bad_expr"

  local mock_state
  local monitored
  before_each(function()
    monitored = {}
    mock_state = {
      on_clear = function() end,
      monitor = function(_, ref)
        monitored[ref] = true
      end,
      watch = function(_, expr)
        if expr == expression then
          return {
            error = nil,
            evaluated = {
              presentationHint = {},
              result = "[0, 1, [2, 3, 4, 5]]",
              type = "list",
              variablesReference = 1,
            },
          }
        elseif expr == bad_expr then
          return {
            error = "Exception occurred during evaluation.",
            evaluated = nil,
          }
        end

        assert(false, "Invalid watch expression")
      end,
      stop_monitor = function(_, ref)
        monitored[ref] = nil
      end,
      variables = function(_, ref)
        if ref == 1 then
          return {
            {
              evaluateName = "a",
              name = "a",
              type = "list",
              value = "[[2, 3, 4, 10]]",
              variablesReference = 2,
            },
            {
              evaluateName = "b",
              name = "b",
              type = "dict",
              value = "{}",
              variablesReference = 3,
            },
          }
        end
        assert(false, "Invalid variable reference passed")
      end,
    }
  end)

  describe("in initial layout", function()
    it("creates lines", function()
      local render_state = render.new_state()
      local component = Hover(expression, mock_state)

      component:render(render_state)
      local expected = { "▸ expr list = [0, 1, [2, 3, 4, 5]]" }
      assert.are.same(expected, render_state.lines)
    end)

    it("creates matches", function()
      local render_state = render.new_state()
      local component = Hover(expression, mock_state)

      component:render(render_state)
      local expected = { { "DapUIDecoration", { 1, 1, 3 } }, { "DapUIType", { 1, 10, 4 } } }
      assert.are.same(expected, render_state.matches)
    end)

    it("creates expand mappings", function()
      local render_state = render.new_state()
      local component = Hover(expression, mock_state)

      component:render(render_state)
      assert.equal(1, #render_state.mappings["expand"])
    end)
  end)

  describe("with expanded expression", function()
    it("creates lines", function()
      local render_state = render.new_state()
      local component = Hover(expression, mock_state)

      component:render(render_state)
      render_state.mappings["expand"][1][1]()
      render_state = render.new_state()
      component:render(render_state)
      local expected = {
        "▾ expr list = [0, 1, [2, 3, 4, 5]]",
        " ▸ a list = [[2, 3, 4, 10]]",
        " ▸ b dict = {}",
      }
      assert.are.same(expected, render_state.lines)
    end)

    it("creates matches", function()
      local render_state = render.new_state()
      local component = Hover(expression, mock_state)

      component:render(render_state)
      render_state.mappings["expand"][1][1]()
      render_state = render.new_state()
      component:render(render_state)
      local expected = {
        { "DapUIDecoration", { 1, 1, 3 } },
        { "DapUIType", { 1, 10, 4 } },
        { "DapUIDecoration", { 2, 2, 1 } },
        { "DapUIVariable", { 2, 6, 1 } },
        { "DapUIType", { 2, 8, 4 } },
        { "DapUIDecoration", { 3, 2, 1 } },
        { "DapUIVariable", { 3, 6, 1 } },
        { "DapUIType", { 3, 8, 4 } },
      }
      assert.are.same(expected, render_state.matches)
    end)

    it("creates expand mappings", function()
      local render_state = render.new_state()
      local component = Hover(expression, mock_state)

      component:render(render_state)
      render_state.mappings["expand"][1][1]()
      render_state = render.new_state()
      component:render(render_state)
      assert.equal(3, #render_state.mappings["expand"])
    end)

    it("closes expanded variable", function()
      local render_state = render.new_state()
      local component = Hover(expression, mock_state)

      component:render(render_state)
      render_state.mappings["expand"][1][1]()
      render_state.mappings["expand"][1][1]()
      render_state = render.new_state()
      component:render(render_state)
      local expected = { "▸ expr list = [0, 1, [2, 3, 4, 5]]" }
      assert.are.same(expected, render_state.lines)
    end)
    it("invalidates render when variables not ready", function()
      local render_state = render.new_state()
      local component = Hover(expression, mock_state)
      mock_state.variables = function()
        return nil
      end

      component:render(render_state)
      render_state.mappings["expand"][1][1]()
      render_state = render.new_state()
      component:render(render_state)
      assert.False(render_state.valid)
    end)
  end)

  describe("with error expression", function()
    it("creates lines", function()
      local render_state = render.new_state()
      local component = Hover(bad_expr, mock_state)

      component:render(render_state)
      local expected = { "▸ bad_expr: Exception occurred during evaluation." }
      assert.are.same(expected, render_state.lines)
    end)

    it("creates matches", function()
      local render_state = render.new_state()
      local component = Hover(bad_expr, mock_state)

      component:render(render_state)
      local expected = { { "DapUIWatchesError", { 1, 1, 3 } } }
      assert.are.same(expected, render_state.matches)
    end)

    it("doesn't create expand mappings", function()
      local render_state = render.new_state()
      local component = Hover(bad_expr, mock_state)

      component:render(render_state)
      assert.equal(0, #render_state.mappings["expand"])
    end)
  end)
end)
