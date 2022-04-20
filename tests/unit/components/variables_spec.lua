local Variables = require("dapui.components.variables")
local render = require("dapui.render")

describe("checking variables", function()
  assert:add_formatter(vim.inspect)

  ---@type UIState
  local mock_state
  local monitored
  local updated
  before_each(function()
    require("dapui.config").setup({})
    monitored = {}
    updated = {}
    mock_state = {
      on_clear = function() end,
      monitor = function(_, ref)
        monitored[ref] = true
      end,
      step_number = function()
        return 1
      end,
      is_monitored = function(_, ref)
        return monitored[ref] ~= nil
      end,
      stop_monitor = function(_, ref)
        monitored[ref] = nil
      end,
      set_variable = function(_, container_ref, variable, value)
        updated[#updated + 1] = { container_ref, variable, value }
      end,
      variables = function(_, ref, first_val)
        if ref == 1 then
          return {
            {
              evaluateName = "a",
              name = "a",
              type = "list",
              value = first_val or "[[2, 3, 4, 10]]",
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
        if ref == 2 then
          return {
            {
              evaluateName = "a[0]",
              name = "a[0]",
              type = "list",
              value = "[2, 3, 4, 10]",
              variablesReference = 4,
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
      local component = Variables(mock_state)

      component:render(canvas, 1, mock_state:variables(1))
      local expected = { "▸ a list = [[2, 3, 4, 10]]", "▸ b dict = {}", "" }
      assert.are.same(expected, canvas.lines)
    end)

    it("creates matches", function()
      local canvas = render.new_canvas()
      local component = Variables(mock_state)

      component:render(canvas, 1, mock_state:variables(1))
      local expected = {
        { "DapUIDecoration", { 1, 1, 3 } },
        { "DapUIVariable", { 1, 5, 1 } },
        { "DapUIType", { 1, 7, 4 } },
        { "DapUIValue", { 1, 14, 15 } },
        { "DapUIDecoration", { 2, 1, 3 } },
        { "DapUIVariable", { 2, 5, 1 } },
        { "DapUIType", { 2, 7, 4 } },
        { "DapUIValue", { 2, 14, 2 } },
      }
      assert.are.same(expected, canvas.matches)
    end)

    it("creates matches with modified value", function()
      local component = Variables(mock_state)

      local canvas = render.new_canvas()
      component:render(canvas, 1, mock_state:variables(1))
      canvas = render.new_canvas()
      component:render(canvas, 1, mock_state:variables(1, "different"))

      local expected = {
        { "DapUIDecoration", { 1, 1, 3 } },
        { "DapUIVariable", { 1, 5, 1 } },
        { "DapUIType", { 1, 7, 4 } },
        { "DapUIModifiedValue", { 1, 14, 9 } },
        { "DapUIDecoration", { 2, 1, 3 } },
        { "DapUIVariable", { 2, 5, 1 } },
        { "DapUIType", { 2, 7, 4 } },
        { "DapUIValue", { 2, 14, 2 } },
      }
      assert.are.same(expected, canvas.matches)
    end)

    it("creates expand mappings", function()
      local canvas = render.new_canvas()
      local component = Variables(mock_state)

      component:render(canvas, 1, mock_state:variables(1))
      assert.equal(2, #canvas.mappings["expand"])
    end)
  end)

  describe("with expanded variable", function()
    it("creates lines", function()
      local canvas = render.new_canvas()
      local component = Variables(mock_state)

      component:render(canvas, 1, mock_state:variables(1))
      canvas.mappings["expand"][1][1]()
      canvas = render.new_canvas()
      component:render(canvas, 1, mock_state:variables(1))
      local expected = {
        "▾ a list = [[2, 3, 4, 10]]",
        " ▸ a[0] list = [2, 3, 4, 10]",
        "▸ b dict = {}",
        "",
      }
      assert.are.same(expected, canvas.lines)
    end)

    it("creates matches", function()
      local canvas = render.new_canvas()
      local component = Variables(mock_state)

      component:render(canvas, 1, mock_state:variables(1))
      canvas.mappings["expand"][1][1]()
      canvas = render.new_canvas()
      component:render(canvas, 1, mock_state:variables(1))
      local expected = {
        { "DapUIDecoration", { 1, 1, 3 } },
        { "DapUIVariable", { 1, 5, 1 } },
        { "DapUIType", { 1, 7, 4 } },
        { "DapUIValue", { 1, 14, 15 } },
        { "DapUIDecoration", { 2, 2, 3 } },
        { "DapUIVariable", { 2, 6, 4 } },
        { "DapUIType", { 2, 11, 4 } },
        { "DapUIValue", { 2, 18, 13 } },
        { "DapUIDecoration", { 3, 1, 3 } },
        { "DapUIVariable", { 3, 5, 1 } },
        { "DapUIType", { 3, 7, 4 } },
        { "DapUIValue", { 3, 14, 2 } },
      }
      assert.are.same(expected, canvas.matches)
    end)

    it("adds monitor", function()
      local canvas = render.new_canvas()
      local component = Variables(mock_state)

      component:render(canvas, 1, mock_state:variables(1))
      canvas.mappings["expand"][1][1]()
      assert(monitored[2])
    end)

    it("creates expand mappings", function()
      local canvas = render.new_canvas()
      local component = Variables(mock_state)

      component:render(canvas, 1, mock_state:variables(1))
      canvas.mappings["expand"][1][1]()
      canvas = render.new_canvas()
      component:render(canvas, 1, mock_state:variables(1))
      assert.equal(3, #canvas.mappings["expand"])
    end)

    it("closes expanded variable", function()
      local canvas = render.new_canvas()
      local component = Variables(mock_state)

      component:render(canvas, 1, mock_state:variables(1))
      canvas.mappings["expand"][1][1]()
      canvas.mappings["expand"][1][1]()
      canvas = render.new_canvas()
      component:render(canvas, 1, mock_state:variables(1))
      local expected = {
        "▸ a list = [[2, 3, 4, 10]]",
        "▸ b dict = {}",
        "",
      }
      assert.are.same(expected, canvas.lines)
    end)

    it("removes monitor", function()
      local canvas = render.new_canvas()
      local component = Variables(mock_state)

      component:render(canvas, 1, mock_state:variables(1))
      canvas.mappings["expand"][1][1]()
      canvas.mappings["expand"][1][1]()
      canvas = render.new_canvas()
      assert.Nil(monitored[2])
    end)

    it("monitors child var when variable reference is changed", function()
      local canvas = render.new_canvas()
      local component = Variables(mock_state)

      local vars = mock_state:variables(1)
      component:render(canvas, 1, vars)
      canvas.mappings["expand"][1][1]()
      canvas = render.new_canvas()
      mock_state.variables = function()
        return nil
      end
      vars[1].variablesReference = 10
      component:render(canvas, 1, vars)
      assert.True(monitored[10])
    end)

    it("truncates variable type", function()
      require("dapui.config").setup({ render = { max_type_length = 3 } })
      local canvas = render.new_canvas()
      local component = Variables(mock_state)

      component:render(canvas, 1, mock_state:variables(1))
      local expected = { "▸ a lis... = [[2, 3, 4, 10]]", "▸ b dic... = {}", "" }
      assert.are.same(expected, canvas.lines)
    end)

    describe("in set mode", function()
      local canvas
      local component
      before_each(function()
        canvas = render.new_canvas()
        component = Variables(mock_state)

        component:render(canvas, 1, mock_state:variables(1))
        canvas.mappings["edit"][1][1]()
        canvas = render.new_canvas()
        component:render(canvas, 1, mock_state:variables(1))
      end)

      it("adds edit prompt", function()
        assert.Not.Nil(canvas.prompt)
      end)

      it("fills prompt with current value", function()
        assert.equal("[[2, 3, 4, 10]]", canvas.prompt.fill)
      end)

      it("updates variable value", function()
        canvas.prompt.callback("new_value")
        assert.are.same({
          1,
          {
            evaluateName = "a",
            name = "a",
            type = "list",
            value = "[[2, 3, 4, 10]]",
            variablesReference = 2,
          },
          "new_value",
        }, updated[1])
      end)

      it("component resets mode", function()
        canvas.prompt.callback("new_value")
        canvas = render.new_canvas()
        component:render(canvas, 1, mock_state:variables(1))
        assert.Nil(component.mode)
      end)
    end)
  end)
end)
