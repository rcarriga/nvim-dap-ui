local dap = require("dap")
local config = require("dapui.config")

local M = {}

local controls_active = false
M.refresh_control_panel = function() end

function M.enable_controls(element)
  if controls_active then
    return
  end
  controls_active = true
  local buffer = element.buffer()

  local group = vim.api.nvim_create_augroup("DAPUIControls", {})
  local win = vim.fn.bufwinid(buffer)

  M.refresh_control_panel = function()
    if win then
      local is_current = win == vim.fn.win_getid()
      if not pcall(vim.api.nvim_win_set_option, win, "winbar", M.controls(is_current)) then
        win = nil
      end
      vim.cmd("redrawstatus!")
    end
  end

  local list_id = "dapui_controls"
  local events = {
    "continue",
    "terminate",
    "restart",
    "disconnect",
    "event_terminated",
    "disconnect",
    "event_exited",
    "event_stopped",
    "threads",
    "event_continued",
  }
  for _, event in ipairs(events) do
    dap.listeners.after[event][list_id] = M.refresh_control_panel
  end

  vim.api.nvim_create_autocmd("BufWinEnter", {
    buffer = buffer,
    group = group,
    callback = function(opts)
      if win then
        return
      end

      win = vim.fn.bufwinid(opts.buf)
      if win == -1 then
        win = nil
        return
      end
      M.refresh_control_panel()
      vim.api.nvim_create_autocmd({ "WinClosed", "BufWinLeave" }, {
        group = group,
        buffer = buffer,
        callback = function()
          if win and not vim.api.nvim_win_is_valid(win) then
            win = nil
          end
        end,
      })
    end,
  })
  -- If original buffer is deleted, this will get newest element buffer
  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = buffer,
    group = group,
    callback = vim.schedule_wrap(function()
      controls_active = false
      M.enable_controls(element)
    end),
  })

  vim.api.nvim_create_autocmd("WinEnter", {
    buffer = buffer,
    group = group,
    callback = function()
      local winbar = M.controls(true)
      vim.api.nvim_win_set_option(vim.api.nvim_get_current_win(), "winbar", winbar)
    end,
  })
  vim.api.nvim_create_autocmd("WinLeave", {
    buffer = buffer,
    group = group,
    callback = function()
      local winbar = M.controls(false)
      vim.api.nvim_win_set_option(vim.api.nvim_get_current_win(), "winbar", winbar)
    end,
  })
end

_G._dapui = {
  play = function()
    local session = dap.session()
    if not session or session.stopped_thread_id then
      dap.continue()
    else
      dap.pause()
    end
  end,
}

setmetatable(_dapui, {
  __index = function(_, key)
    return function()
      return dap[key]()
    end
  end,
})
function M.controls(is_active)
  local session = dap.session()

  local running = (session and not session.stopped_thread_id)

  local avail_hl = function(group, allow_running)
    if not session or (not allow_running and running) then
      return is_active and "DapUIUnavailable" or "DapUIUnavailableNC"
    end
    return group
  end

  local icons = config.controls.icons
  local elems = {
    {
      func = "play",
      icon = running and icons.pause or icons.play,
      hl = is_active and "DapUIPlayPause" or "DapUIPlayPauseNC",
    },
    { func = "step_into", hl = avail_hl(is_active and "DapUIStepInto" or "DapUIStepIntoNC") },
    { func = "step_over", hl = avail_hl(is_active and "DapUIStepOver" or "DapUIStepOverNC") },
    { func = "step_out", hl = avail_hl(is_active and "DapUIStepOut" or "DapUIStepOutNC") },
    { func = "step_back", hl = avail_hl(is_active and "DapUIStepBack" or "DapUIStepBackNC") },
    { func = "run_last", hl = is_active and "DapUIRestart" or "DapUIRestartNC" },
    { func = "terminate", hl = avail_hl(is_active and "DapUIStop" or "DapUIStopNC", true) },
    { func = "disconnect", hl = avail_hl(is_active and "DapUIStop" or "DapUIStopNC", true) },
  }
  local bar = ""
  for _, elem in ipairs(elems) do
    bar = bar
      .. ("  %%#%s#%%0@v:lua._dapui.%s@%s%%#0#"):format(
        elem.hl,
        elem.func,
        elem.icon or icons[elem.func]
      )
  end
  return bar
end

return M
