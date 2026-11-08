local api = vim.api
local dap = require("dap")
local config = require("dapui.config")

describe("control panel", function()
  local controls, element, buffer, initial_win, session
  local buffers
  local original_session = dap.session

  local function counts()
    local result = {}
    for _, command in ipairs(api.nvim_get_autocmds({ group = "DAPUIControls" })) do
      result[command.event] = (result[command.event] or 0) + 1
    end
    return result
  end

  local function open()
    vim.cmd("vsplit")
    local win = api.nvim_get_current_win()
    api.nvim_win_set_buf(win, element.buffer())
    controls.enable_controls(element)
    controls.refresh_control_panel()
    return win
  end

  local function cycle()
    api.nvim_win_close(open(), true)
  end

  before_each(function()
    package.loaded["dapui.controls"] = nil
    controls = require("dapui.controls")
    config.setup({})
    initial_win = api.nvim_get_current_win()
    buffers = {}
    buffer = nil
    session = nil
    dap.session = function()
      return session
    end
    element = {
      buffer = function()
        if not buffer or not api.nvim_buf_is_valid(buffer) then
          buffer = api.nvim_create_buf(false, true)
          buffers[#buffers + 1] = buffer
        end
        return buffer
      end,
    }
  end)

  after_each(function()
    api.nvim_del_augroup_by_name("DAPUIControls")
    for _, listeners in pairs(dap.listeners.after) do
      listeners.dapui_controls = nil
    end
    dap.session = original_session
    for _, win in ipairs(api.nvim_list_wins()) do
      if win ~= initial_win then
        api.nvim_win_close(win, true)
      end
    end
    for _, buf in ipairs(buffers) do
      if api.nvim_buf_is_valid(buf) then
        api.nvim_buf_delete(buf, { force = true })
      end
    end
  end)

  it("keeps registrations stable across repeated open and close cycles", function()
    cycle()
    cycle()
    local before = counts()
    for _ = 1, 25 do
      cycle()
      assert.same(before, counts())
    end
  end)

  it("refreshes the controls after every reopen", function()
    for _ = 1, 3 do
      local win = open()
      session = {}
      dap.listeners.after.event_continued.dapui_controls()
      assert.equal(controls.controls(true), api.nvim_win_get_option(win, "winbar"))
      session.stopped_thread_id = 1
      dap.listeners.after.event_stopped.dapui_controls()
      assert.equal(controls.controls(true), api.nvim_win_get_option(win, "winbar"))
      api.nvim_win_close(win, true)
    end
  end)

  it("acquires a buffer first shown after controls are enabled", function()
    controls.enable_controls(element)
    local win = open()
    assert.equal(controls.controls(true), api.nvim_win_get_option(win, "winbar"))
  end)

  it("does not refresh a window after the control buffer is hidden", function()
    local win = open()
    api.nvim_win_set_buf(win, api.nvim_win_get_buf(initial_win))
    api.nvim_win_set_option(win, "winbar", "other buffer")
    dap.listeners.after.event_stopped.dapui_controls()
    assert.equal("other buffer", api.nvim_win_get_option(win, "winbar"))
    api.nvim_win_set_buf(win, element.buffer())
    assert.equal(controls.controls(true), api.nvim_win_get_option(win, "winbar"))
  end)

  it("updates active and inactive highlights as focus changes", function()
    local win = open()
    api.nvim_set_current_win(initial_win)
    assert.equal(controls.controls(false), api.nvim_win_get_option(win, "winbar"))
    dap.listeners.after.event_stopped.dapui_controls()
    assert.equal(controls.controls(false), api.nvim_win_get_option(win, "winbar"))
    api.nvim_set_current_win(win)
    assert.equal(controls.controls(true), api.nvim_win_get_option(win, "winbar"))
  end)

  it("replaces registrations when the control buffer is wiped", function()
    cycle()
    local before = counts()
    for _ = 1, 3 do
      local old_buffer = element.buffer()
      api.nvim_buf_delete(old_buffer, { force = true })
      assert.True(vim.wait(1000, function()
        return buffer ~= old_buffer
      end))
      assert.same(before, counts())
      for _, command in ipairs(api.nvim_get_autocmds({ group = "DAPUIControls" })) do
        assert.equal(buffer, command.buffer)
      end
      local win = open()
      dap.listeners.after.event_stopped.dapui_controls()
      assert.equal(controls.controls(true), api.nvim_win_get_option(win, "winbar"))
      api.nvim_win_close(win, true)
    end
  end)

  it("does not register more handlers when enabled again", function()
    open()
    local before = counts()
    local refresh = dap.listeners.after.event_stopped.dapui_controls
    for _ = 1, 3 do
      controls.enable_controls(element)
      assert.same(before, counts())
      assert.equal(refresh, dap.listeners.after.event_stopped.dapui_controls)
    end
  end)
end)
