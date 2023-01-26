local api = vim.api
local util = require("dapui.util")
local windows = require("dapui.windows")

describe("checking window layout", function()
  local layout
  local win_configs = {
    { id = "a", size = 0.6 },
    { id = "b", size = 0.2 },
    { id = "c", size = 0.2 },
  }
  local buffers

  before_each(function()
    buffers = {}
    for index, win_conf in ipairs(win_configs) do
      local buf = api.nvim_create_buf(true, true)
      api.nvim_buf_set_name(buf, win_conf.id)
      buffers[index] = function()
        return buf
      end
    end

    layout = windows.area_layout(10, "right", win_configs, buffers)
    layout:open()
  end)

  after_each(function()
    for _, get_buf in ipairs(buffers) do
      vim.api.nvim_buf_delete(get_buf(), { force = true })
    end
    layout:close()
  end)

  it("opens all windows", function()
    for _, win_config in pairs(win_configs) do
      assert.Not.equal(-1, vim.fn.bufwinnr(win_config.id))
    end
  end)

  it("sizes area correctly", function()
    assert.equal(10, api.nvim_win_get_width(vim.fn.bufwinid(win_configs[1].id)))
  end)

  it("sizes windows correctly", function()
    local total_size = 0
    local heights = {}
    for _, win_config in pairs(win_configs) do
      local win = vim.fn.bufwinid(win_config.id)
      heights[win_config.id] = api.nvim_win_get_height(win)
      total_size = total_size + heights[win_config.id]
    end

    for i, win_config in ipairs(win_configs) do
      assert.equal(util.round(total_size * win_configs[i].size), heights[win_config.id])
    end
  end)

  it("closes all windows", function()
    layout:close()
    for _, win_config in pairs(win_configs) do
      assert.equal(-1, vim.fn.bufwinid(win_config.id))
    end
  end)

  it("retains sizes on close", function()
    local total_size = 0
    local heights = {}
    vim.api.nvim_win_set_height(vim.fn.bufwinid(win_configs[1].id), 1)
    vim.api.nvim_win_set_width(vim.fn.bufwinid(win_configs[1].id), 20)
    for _, win_config in pairs(win_configs) do
      local win = vim.fn.bufwinid(win_config.id)
      heights[win_config.id] = api.nvim_win_get_height(win)
      total_size = total_size + heights[win_config.id]
    end
    layout:update_sizes()
    layout:close()
    layout:open()
    assert.equal(20, api.nvim_win_get_width(vim.fn.bufwinid(win_configs[1].id)))
    for _, win_config in pairs(win_configs) do
      local win = vim.fn.bufwinid(win_config.id)
      assert.equal(heights[win_config.id], api.nvim_win_get_height(win))
    end
  end)
end)
