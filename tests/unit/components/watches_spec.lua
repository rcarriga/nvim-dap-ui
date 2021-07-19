local Watches = require("dapui.components.watches")
local render = require("dapui.render")

describe("checking hover", function()
  require("dapui.config").setup({})
  assert:add_formatter(vim.inspect)

  describe("in initial layout", function()
    local data = {}
    before_each(function()
      data.mock_state = {
        on_clear = function() end,
        watches = function(_)
          return {}
        end,
      }
      data.render_state = render.new_state()
      data.component = Watches(data.mock_state)
      data.component:render(data.render_state)
    end)

    it("creates lines", function()
      local expected = { "No Expressions", "" }
      assert.are.same(expected, data.render_state.lines)
    end)

    it("creates matches", function()
      local expected = { { "DapUIWatchesEmpty", { 1 } } }
      assert.are.same(expected, data.render_state.matches)
    end)
  end)

  describe("with valid expression", function()
    local expression = "expr"
    local data = {}
    before_each(function()
      data.monitored = {}
      data.watches = {}
      data.mock_state = {
        on_clear = function() end,
        monitor = function(_, ref)
          data.monitored[ref] = true
        end,
        add_watch = function(value)
          data.watches[value] = true
        end,
        remove_watch = function(value)
          data.watches[value] = nil
        end,
        watches = function(_)
          return {
            [expression] = {
              evaluated = {
                presentationHint = {},
                result = "[0, 1, [2, 3, 4, 5]]",
                type = "list",
                variablesReference = 1,
              },
            },
          }
        end,
        stop_monitor = function(_, ref)
          data.monitored[ref] = nil
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
      data.component = Watches(data.mock_state)
      data.render_state = render.new_state()
      data.component:render(data.render_state)
      data.render_state.prompt.callback(expression)
      data.render_state = render.new_state()
      data.component:render(data.render_state)
    end)

    it("creates lines", function()
      local expected = { " ▸ expr list = [0, 1, [2, 3, 4, 5]]", "" }
      assert.are.same(expected, data.render_state.lines)
    end)

    it("creates matches", function()
      local expected = { { "DapUIWatchesValue", { 1, 1, 3 } }, { "DapUIType", { 1, 11, 4 } } }
      assert.are.same(expected, data.render_state.matches)
    end)

    describe("expanded", function()
      before_each(function()
        data.expanded_render = render.new_state()
        data.component:render(data.expanded_render)
        data.expanded_render.mappings.expand[1][1]()
        data.expanded_render = render.new_state()
        data.component:render(data.expanded_render)
      end)

      it("creates lines", function()
        local expected = {
          " ▾ expr list = [0, 1, [2, 3, 4, 5]]",
          "  ▸ a list = [[2, 3, 4, 10]]",
          "  ▸ b dict = {}",
          "",
        }
        assert.are.same(expected, data.expanded_render.lines)
      end)

      it("creates matches", function()
        local expected = {
          { "DapUIWatchesValue", { 1, 1, 3 } },
          { "DapUIType", { 1, 11, 4 } },
          { "DapUIDecoration", { 2, 3, 1 } },
          { "DapUIVariable", { 2, 7, 1 } },
          { "DapUIType", { 2, 9, 4 } },
          { "DapUIDecoration", { 3, 3, 1 } },
          { "DapUIVariable", { 3, 7, 1 } },
          { "DapUIType", { 3, 9, 4 } },
        }
        assert.are.same(expected, data.expanded_render.matches)
      end)

      it("collapses variable", function()
        local collapsed_render = render.new_state()
        data.expanded_render.mappings.expand[1][1]()
        data.component:render(collapsed_render)
        assert.equal(2, #collapsed_render.lines)
      end)
    end)

    it("removes expression", function()
      data.render_state.mappings.remove[1][1]()
      local deleted_render = render.new_state()
      data.component:render(deleted_render)
      local expected = { "No Expressions", "" }
      assert.are.same(expected, deleted_render.lines)
    end)
  end)

  describe("with error expression", function()
    local bad_expr = "bad_expr"
    local data = {}
    before_each(function()
      data.watches = {}
      data.mock_state = {
        on_clear = function() end,
        add_watch = function(value)
          data.watches[value] = true
        end,
        watches = function(_)
          return {
            [bad_expr] = {
              error = "Error message",
            },
          }
        end,
      }
      data.component = Watches(data.mock_state)

      data.render_state = render.new_state()
      data.component:render(data.render_state)
      data.render_state.prompt.callback(bad_expr)
      data.render_state = render.new_state()
      data.component:render(data.render_state)
    end)

    it("creates lines", function()
      local expected = { " ▸ bad_expr: Error message", "" }
      assert.are.same(expected, data.render_state.lines)
    end)

    it("creates matches", function()
      local expected = { { "DapUIWatchesError", { 1, 1, 3 } } }
      assert.are.same(expected, data.render_state.matches)
    end)
  end)
end)
