local Variables = require("dapui.components.variables")
local render = require("dapui.render")

describe("checking variables", function()
  require("dapui.config").setup({})

  ---@type UIState
  local mock_state
  local monitored
  local updated
  before_each(function()
    monitored = {}
    updated = {}
    mock_state = {
      on_clear = function() end,
      monitor = function(_, ref)
        monitored[ref] = true
      end,
      stop_monitor = function(_, ref)
        monitored[ref] = nil
      end,
      set_variable = function(_, container_ref, variable, value)
        updated[#updated + 1] = { container_ref, variable, value }
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
      local render_state = render.new_state()
      local component = Variables(mock_state)

      component:render(render_state, 1, mock_state:variables(1))
      local expected = { "▸ a list = [[2, 3, 4, 10]]", "▸ b dict = {}" }
      assert.are.same(expected, render_state.lines)
    end)

    it("creates matches", function()
      local render_state = render.new_state()
      local component = Variables(mock_state)

      component:render(render_state, 1, mock_state:variables(1))
      local expected = {
        { "DapUIDecoration", { 1, 1, 1 } },
        { "DapUIVariable", { 1, 5, 1 } },
        { "DapUIType", { 1, 7, 4 } },
        { "DapUIDecoration", { 2, 1, 1 } },
        { "DapUIVariable", { 2, 5, 1 } },
        { "DapUIType", { 2, 7, 4 } },
      }
      assert.are.same(expected, render_state.matches)
    end)

    it("creates expand mappings", function()
      local render_state = render.new_state()
      local component = Variables(mock_state)

      component:render(render_state, 1, mock_state:variables(1))
      assert.equal(2, #render_state.mappings["expand"])
    end)
  end)

  describe("with expanded variable", function()
    it("creates lines", function()
      local render_state = render.new_state()
      local component = Variables(mock_state)

      component:render(render_state, 1, mock_state:variables(1))
      render_state.mappings["expand"][1][1]()
      render_state = render.new_state()
      component:render(render_state, 1, mock_state:variables(1))
      local expected = {
        "▾ a list = [[2, 3, 4, 10]]",
        " ▸ a[0] list = [2, 3, 4, 10]",
        "▸ b dict = {}",
      }
      assert.are.same(expected, render_state.lines)
    end)

    it("creates matches", function()
      local render_state = render.new_state()
      local component = Variables(mock_state)

      component:render(render_state, 1, mock_state:variables(1))
      render_state.mappings["expand"][1][1]()
      render_state = render.new_state()
      component:render(render_state, 1, mock_state:variables(1))
      local expected = {
        { "DapUIDecoration", { 1, 1, 1 } },
        { "DapUIVariable", { 1, 5, 1 } },
        { "DapUIType", { 1, 7, 4 } },
        { "DapUIDecoration", { 2, 2, 1 } },
        { "DapUIVariable", { 2, 6, 4 } },
        { "DapUIType", { 2, 11, 4 } },
        { "DapUIDecoration", { 3, 1, 1 } },
        { "DapUIVariable", { 3, 5, 1 } },
        { "DapUIType", { 3, 7, 4 } },
      }
      assert.are.same(expected, render_state.matches)
    end)

    it("adds monitor", function()
      local render_state = render.new_state()
      local component = Variables(mock_state)

      component:render(render_state, 1, mock_state:variables(1))
      render_state.mappings["expand"][1][1]()
      assert(monitored[2])
    end)

    it("creates expand mappings", function()
      local render_state = render.new_state()
      local component = Variables(mock_state)

      component:render(render_state, 1, mock_state:variables(1))
      render_state.mappings["expand"][1][1]()
      render_state = render.new_state()
      component:render(render_state, 1, mock_state:variables(1))
      assert.equal(3, #render_state.mappings["expand"])
    end)

    it("closes expanded variable", function()
      local render_state = render.new_state()
      local component = Variables(mock_state)

      component:render(render_state, 1, mock_state:variables(1))
      render_state.mappings["expand"][1][1]()
      render_state.mappings["expand"][1][1]()
      render_state = render.new_state()
      component:render(render_state, 1, mock_state:variables(1))
      local expected = {
        "▸ a list = [[2, 3, 4, 10]]",
        "▸ b dict = {}",
      }
      assert.are.same(expected, render_state.lines)
    end)

    it("removes monitor", function()
      local render_state = render.new_state()
      local component = Variables(mock_state)

      component:render(render_state, 1, mock_state:variables(1))
      render_state.mappings["expand"][1][1]()
      render_state.mappings["expand"][1][1]()
      render_state = render.new_state()
      assert.Nil(monitored[2])
    end)

    it("invalidates render when variables not ready", function()
      local render_state = render.new_state()
      local component = Variables(mock_state)

      local vars = mock_state:variables(1)
      component:render(render_state, 1, vars)
      render_state.mappings["expand"][1][1]()
      render_state = render.new_state()
      mock_state.variables = function()
        return nil
      end
      component:render(render_state, 1, vars)
      assert.False(render_state.valid)
    end)

    it("creates edit mappings", function() end)

    describe("in set mode", function()
      local render_state
      local component
      before_each(function()
        render_state = render.new_state()
        component = Variables(mock_state)

        component:render(render_state, 1, mock_state:variables(1))
        render_state.mappings["edit"][1][1]()
        render_state = render.new_state()
        component:render(render_state, 1, mock_state:variables(1))
      end)

      it("adds edit prompt", function()
        assert.Not.Nil(render_state.prompt)
      end)

      it("fills prompt with current value", function()
        assert.equal("[[2, 3, 4, 10]]", render_state.prompt.fill)
      end)

      it("updates variable value", function()
        render_state.prompt.callback("new_value")
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
        render_state.prompt.callback("new_value")
        render_state = render.new_state()
        component:render(render_state, 1, mock_state:variables(1))
        assert.Nil(component.mode)
      end)
    end)
  end)
end)
