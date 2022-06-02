local config = require("dapui.config")

describe("checking setup function", function()
  it("allows nil config", function()
    config.setup()
    assert.equal(config.icons().expanded, "▾")
  end)

  it("allows empty config", function()
    config.setup({})
    assert.equal(config.icons().expanded, "▾")
  end)

  it("allows overriding values", function()
    config.setup({ icons = { expanded = "X" } })
    assert.equal(config.icons().expanded, "X")
  end)

  it("fills mappings", function()
    config.setup({ mappings = { edit = "e" } })
    assert.same({ "e" }, config.mappings()["edit"])
  end)

  it("fills elements", function()
    config.setup({ layouts = { { size = 10, position = "left", elements = { "scopes" } } } })
    assert.same({ { id = "scopes", size = 1 } }, config.layouts()[1].elements)
  end)

  it("fills elements with proportional size", function()
    config.setup({
      layouts = { { size = 10, position = "left", elements = { "scopes", "stacks" } } },
    })
    assert.same(
      { { id = "scopes", size = 0.5 }, { id = "stacks", size = 0.5 } },
      config.layouts()[1].elements
    )
  end)
end)
