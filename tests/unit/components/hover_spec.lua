local Hover = require("dapui.components.hover")
local render = require("dapui.render")

describe("checking hover", function()
  require("dapui.config").setup({})
  after_each(function()
    require("dapui.config").setup({})
  end)
  assert:add_formatter(vim.inspect)

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
      step_number = function()
        return 1
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
      local canvas = render.new_canvas()
      local component = Hover(expression, mock_state)

      component:render(canvas)
      local expected = { "▸ expr list = [0, 1, [2, 3, 4, 5]]" }
      assert.are.same(expected, canvas.lines)
    end)

    it("truncates types", function()
      require("dapui.config").setup({ render = { max_type_length = 3 } })
      local canvas = render.new_canvas()
      local component = Hover(expression, mock_state)

      component:render(canvas)
      local expected = { "▸ expr lis... = [0, 1, [2, 3, 4, 5]]" }
      assert.are.same(expected, canvas.lines)
    end)

    it("creates matches", function()
      local canvas = render.new_canvas()
      local component = Hover(expression, mock_state)

      component:render(canvas)
      local expected = {
        { "DapUIDecoration", { 1, 1, 4 } },
        { "DapUIType", { 1, 10, 4 } },
        { "DapUIValue", { 1, 17, 20 } },
      }
      assert.are.same(expected, canvas.matches)
    end)

    it("creates expand mappings", function()
      local canvas = render.new_canvas()
      local component = Hover(expression, mock_state)

      component:render(canvas)
      assert.equal(1, #canvas.mappings["expand"])
    end)
  end)

  describe("with expanded expression", function()
    it("creates lines", function()
      local canvas = render.new_canvas()
      local component = Hover(expression, mock_state)

      component:render(canvas)
      canvas.mappings["expand"][1][1]()
      canvas = render.new_canvas()
      component:render(canvas)
      local expected = {
        "▾ expr list = [0, 1, [2, 3, 4, 5]]",
        " ▸ a list = [[2, 3, 4, 10]]",
        " ▸ b dict = {}",
      }
      assert.are.same(expected, canvas.lines)
    end)

    it("creates matches", function()
      local canvas = render.new_canvas()
      local component = Hover(expression, mock_state)

      component:render(canvas)
      canvas.mappings["expand"][1][1]()
      canvas = render.new_canvas()
      component:render(canvas)
      local expected = {
        { "DapUIDecoration", { 1, 1, 4 } },
        { "DapUIType", { 1, 10, 4 } },
        { "DapUIValue", { 1, 17, 20 } },
        { "DapUIDecoration", { 2, 2, 3 } },
        { "DapUIVariable", { 2, 6, 1 } },
        { "DapUIType", { 2, 8, 4 } },
        { "DapUIValue", { 2, 15, 15 } },
        { "DapUIDecoration", { 3, 2, 3 } },
        { "DapUIVariable", { 3, 6, 1 } },
        { "DapUIType", { 3, 8, 4 } },
        { "DapUIValue", { 3, 15, 2 } },
      }
      assert.are.same(expected, canvas.matches)
    end)

    it("creates expand mappings", function()
      local canvas = render.new_canvas()
      local component = Hover(expression, mock_state)

      component:render(canvas)
      canvas.mappings["expand"][1][1]()
      canvas = render.new_canvas()
      component:render(canvas)
      assert.equal(3, #canvas.mappings["expand"])
    end)

    it("closes expanded variable", function()
      local canvas = render.new_canvas()
      local component = Hover(expression, mock_state)

      component:render(canvas)
      canvas.mappings["expand"][1][1]()
      canvas.mappings["expand"][1][1]()
      canvas = render.new_canvas()
      component:render(canvas)
      local expected = { "▸ expr list = [0, 1, [2, 3, 4, 5]]" }
      assert.are.same(expected, canvas.lines)
    end)
    it("invalidates render when variables not ready", function()
      local canvas = render.new_canvas()
      local component = Hover(expression, mock_state)
      mock_state.variables = function()
        return nil
      end

      component:render(canvas)
      canvas.mappings["expand"][1][1]()
      canvas = render.new_canvas()
      component:render(canvas)
      assert.False(canvas.valid)
    end)
  end)

  describe("with error expression", function()
    it("creates lines", function()
      local canvas = render.new_canvas()
      local component = Hover(bad_expr, mock_state)

      component:render(canvas)
      local expected = { "▸ bad_expr: Exception occurred during evaluation." }
      assert.are.same(expected, canvas.lines)
    end)

    it("creates matches", function()
      local canvas = render.new_canvas()
      local component = Hover(bad_expr, mock_state)

      component:render(canvas)
      local expected = { { "DapUIWatchesError", { 1, 1, 4 } }, { "DapUIValue", { 1, 15, 37 } } }
      assert.are.same(expected, canvas.matches)
    end)

    it("doesn't create expand mappings", function()
      local canvas = render.new_canvas()
      local component = Hover(bad_expr, mock_state)

      component:render(canvas)
      assert.equal(0, #canvas.mappings["expand"])
    end)
  end)

  describe("in set mode", function()
    local canvas
    local component
    local updated
    before_each(function()
      canvas = render.new_canvas()
      component = Hover(expression, mock_state)
      updated = {}

      component:render(canvas)
      canvas.mappings["edit"][1][1]()
      canvas = render.new_canvas()
      component:render(canvas)

      mock_state.set_variable = function(_, container_ref, variable, value)
        updated[#updated + 1] = { container_ref, variable, value }
      end
    end)

    it("adds edit prompt", function()
      assert.Not.Nil(canvas.prompt)
    end)

    it("fills prompt with current value", function()
      assert.equal("[0, 1, [2, 3, 4, 5]]", canvas.prompt.fill)
    end)

    it("updates variable value", function()
      canvas.prompt.callback("new_value")
      assert.are.same({
        nil,
        {
          evaluateName = "expr",
          presentationHint = {},
          result = "[0, 1, [2, 3, 4, 5]]",
          type = "list",
          variablesReference = 1,
        },
        "new_value",
      }, updated[1])
    end)

    it("component resets mode", function()
      canvas.prompt.callback("new_value")
      canvas = render.new_canvas()
      component:render(canvas)
      assert.Nil(component.mode)
    end)
  end)
end)
