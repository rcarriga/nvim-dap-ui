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
end)
