local api = vim.api
local config = require("dapui.config")
local util = require("dapui.util")
local WindowLayout = require("dapui.windows.layout")

describe("checking window layout", function()
  local layout
  local win_configs = {
    { id = "a", size = 0.6, element = { name = "A" } },
    { id = "b", size = 0.2, element = { name = "B" } },
    { id = "c", size = 0.2, element = { name = "C" } },
  }
  local registered
  local run

  before_each(function()
    config.setup()
    registered = {}
    run = {}
    local layout_conf = config.layouts()[1]
    local position = layout_conf.position
    local width = layout_conf.size
    local open_cmd = position == "left" and "topleft" or "botright"
    local function open_sidebar_win(index)
      vim.cmd(index == 1 and open_cmd .. " " .. width .. "vsplit" or "split")
    end

    local loop = {
      register_buffer = function(name, buf)
        registered[name] = buf
        api.nvim_buf_set_name(buf, name)
      end,
      run = function(name)
        run[#run + 1] = name
      end,
    }

    layout = WindowLayout({
      open_index = open_sidebar_win,
      get_win_size = api.nvim_win_get_height,
      get_area_size = api.nvim_win_get_width,
      set_win_size = api.nvim_win_set_height,
      set_area_size = api.nvim_win_set_width,
      win_states = win_configs,
      area_state = { size = 10 },
      loop = loop,
    })
    layout:open()
  end)

  after_each(function()
    layout:close()
  end)

  it("opens all windows", function()
    for _, win_config in pairs(win_configs) do
      assert.Not.equal(-1, vim.fn.bufwinnr(win_config.element.name))
    end
  end)

  it("registers elements", function()
    for _, win_config in ipairs(win_configs) do
      assert(registered[win_config.element.name])
    end
  end)

  it("runs elements", function()
    for i, win_config in ipairs(win_configs) do
      assert(registered[win_config.element.name])
      assert(win_config.element.name, run[i])
    end
  end)

  it("sizes area correctly", function()
    assert.equal(10, api.nvim_win_get_width(vim.fn.bufwinid(win_configs[1].element.name)))
  end)

  it("sizes windows correctly", function()
    local total_size = 0
    local heights = {}
    for _, win_config in pairs(win_configs) do
      local win = vim.fn.bufwinid(win_config.element.name)
      heights[win_config.element.name] = api.nvim_win_get_height(win)
      total_size = total_size + heights[win_config.element.name]
    end

    for i, win_config in ipairs(win_configs) do
      assert.equal(util.round(total_size * win_configs[i].size), heights[win_config.element.name])
    end
  end)

  it("closes all windows", function()
    layout:close()
    for _, win_config in pairs(win_configs) do
      assert.equal(-1, vim.fn.bufwinid(win_config.element.name))
    end
  end)

  it("retains sizes on close", function()
    local total_size = 0
    local heights = {}
    vim.api.nvim_win_set_height(vim.fn.bufwinid(win_configs[1].element.name), 1)
    vim.api.nvim_win_set_width(vim.fn.bufwinid(win_configs[1].element.name), 20)
    for _, win_config in pairs(win_configs) do
      local win = vim.fn.bufwinid(win_config.element.name)
      heights[win_config.element.name] = api.nvim_win_get_height(win)
      total_size = total_size + heights[win_config.element.name]
    end
    layout:update_sizes()
    layout:close()
    layout:open()
    assert.equal(20, api.nvim_win_get_width(vim.fn.bufwinid(win_configs[1].element.name)))
    for _, win_config in pairs(win_configs) do
      local win = vim.fn.bufwinid(win_config.element.name)
      assert.equal(heights[win_config.element.name], api.nvim_win_get_height(win))
    end
  end)
end)
