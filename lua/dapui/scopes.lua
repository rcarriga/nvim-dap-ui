local M = {}
local listener_id = "dapui_scopes"

local EXPAND_STATE = {
  COLLAPSED = nil,
  TO_EXPAND = 1,
  EXPANDED = 2
}

M.buffer_info = {
  name = "DAP Scopes",
  settings = {
    filetype = "dapui_scopes"
  },
  on_open = function()
    local buf_num = vim.fn.bufnr(M.buffer_info.name)
    vim.api.nvim_buf_set_keymap(buf_num, "n", "<CR>", "<Cmd>lua require('dapui.scopes').toggle_reference()<CR>", {})
  end
}

local Scopes = {
  config = {},
  scopes = {},
  references = {},
  line_variable_map = {},
  expanded_references = {}
}

function Scopes:load_config(user_config)
  self.config = {
    prefix = {
      expanded = user_config.expanded_icon or user_config.use_icons and "⯆ " or "v ",
      collapsed = user_config.collapsed_icon or (user_config.use_icons and "⯈ " or "> "),
      circular = user_config.circular_ref_icon or (user_config.use_icons and "↺ " or "o ")
    }
  }
end

function Scopes:reference_prefix(ref)
  if ref == 0 then
    return "  "
  elseif self.expanded_references[ref] == EXPAND_STATE.EXPANDED then
    return self.config.prefix.circular
  end
  return self.expanded_references[ref] == EXPAND_STATE.COLLAPSED and self.config.prefix.collapsed or
    self.config.prefix.expanded
end

function Scopes:render_variables(reference, render_state, indent)
  self.expanded_references[reference] = EXPAND_STATE.EXPANDED
  for _, variable in pairs(self.references[reference] or {}) do
    local line_no = render_state:length() + 1
    self.line_variable_map[line_no] = variable.variablesReference

    local new_line = string.rep(" ", indent)

    render_state:add_match("DapUISpecial", line_no, #new_line + 1, 2)
    new_line = new_line .. self:reference_prefix(variable.variablesReference)

    render_state:add_match("DapUIVariable", line_no, #new_line + 1, #variable.name)
    new_line = new_line .. variable.name

    if #(variable.type or "") > 0 then
      new_line = new_line .. " ("
      render_state:add_match("DapUIType", line_no, #new_line + 1, #variable.type)
      new_line = new_line .. variable.type .. ")"
    end

    if #(variable.value or "") > 0 then
      new_line = new_line .. ": "
      local value_start = #new_line
      new_line = new_line .. variable.value

      for i, line in pairs(vim.split(new_line, "\n")) do
        if i > 1 then
          line = string.rep(" ", value_start - 2) .. line
        end
        render_state:add_line(line)
      end
    else
      render_state:add_line(new_line)
    end

    if self.expanded_references[variable.variablesReference] == EXPAND_STATE.TO_EXPAND then
      self:render_variables(variable.variablesReference, render_state, indent + 1)
    end
  end
end

function Scopes:render_scopes(render_state)
  for i, scope in pairs(self.scopes or {}) do
    render_state:add_match("DapUIScope", render_state:length() + 1, 1, #scope.name)
    render_state:add_line(scope.name .. ":")
    self:render_variables(scope.variablesReference, render_state, 1)
    if i < #self.scopes then
      render_state:add_line()
    end
  end
end

function Scopes:refresh(session)
  if not session or not session.current_frame then
    return
  end
  self.expanded_references =
    vim.tbl_map(
    function(val)
      return val == EXPAND_STATE.EXPANDED and EXPAND_STATE.TO_EXPAND or val
    end,
    self.expanded_references
  )
  local win = vim.fn["bufwinnr"](M.buffer_info.name)
  if win >= 0 then
    local render_state = require("dapui.render").init_state()
    self:render_scopes(render_state)
    render_state:render_buffer(win, M.buffer_info.name)
  end
end

function M.toggle_reference()
  local current_ref = Scopes.line_variable_map[vim.fn["getbufinfo"](M.buffer_info.name)[1].lnum]
  if not current_ref then
    return
  end
  local session = require("dap").session()
  if not session then
    print("No active session to query")
    return
  end
  if Scopes.expanded_references[current_ref] ~= EXPAND_STATE.COLLAPSED then
    Scopes.expanded_references[current_ref] = EXPAND_STATE.COLLAPSED
    Scopes:refresh(session)
  else
    Scopes.expanded_references[current_ref] = EXPAND_STATE.TO_EXPAND
    session:request(
      "variables",
      {variablesReference = current_ref},
      function()
        -- nvim-dap requires a callback function to trigger other listeners
      end
    )
  end
end

function M.setup(config)
  Scopes:load_config(config)
  vim.cmd("hi default link DapUIVariable Normal")
  vim.cmd("hi default DapUIScope guifg=#A9FF68")
  vim.cmd("hi default DapUIType guifg=#D484FF")
  vim.cmd("hi default DapUISpecial guifg=#00F1F5")
  local dap = require("dap")
  dap.listeners.after.variables[listener_id] = function(session, err, response, request)
    if not err then
      Scopes.references[request.variablesReference] = response.variables
      Scopes:refresh(session)
    end
  end

  dap.listeners.after.scopes[listener_id] = function(_, err, response)
    if not err then
      local references = {}
      for _, scope in pairs(response.scopes) do
        references[scope.variablesReference] = scope.variables
      end
      Scopes.scopes = vim.tbl_extend("force", Scopes.scopes, response.scopes)
      Scopes.references = vim.tbl_extend("force", Scopes.references, references)
    end
  end
  dap.listeners.after.event_stopped[listener_id] = function(session)
    Scopes:refresh(session)
  end
end

return M
