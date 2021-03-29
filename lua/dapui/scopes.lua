vim.cmd("hi default link DapUIVariable Normal")
vim.cmd("hi default DapUIScope guifg=#A9FF68")
vim.cmd("hi default DapUIType guifg=#D484FF")
vim.cmd("hi default DapUISpecial guifg=#00F1F5")

local EXPAND_STATE = {
  COLLAPSED = nil,
  TO_EXPAND = 1,
  EXPANDED = 2
}

local Scopes = {
  render_receiver = function()
  end,
  config = {},
  scopes = {},
  references = {},
  line_variable_map = {},
  expanded_references = {}
}

function Scopes:reference_prefix(ref)
  if ref == 0 then
    return "  "
  elseif self.expanded_references[ref] == EXPAND_STATE.EXPANDED then
    return self.config.icons.circular
  end
  return self.expanded_references[ref] == EXPAND_STATE.COLLAPSED and self.config.icons.collapsed or
    self.config.icons.expanded
end

function Scopes:render_variables(reference, render_state, indent)
  self.expanded_references[reference] = EXPAND_STATE.EXPANDED
  for _, variable in pairs(self.references[reference] or {}) do
    local line_no = render_state:length() + 1
    self.line_variable_map[line_no] = variable.variablesReference

    local new_line = string.rep(" ", indent)
    local prefix = self:reference_prefix(variable.variablesReference)
    render_state:add_match("DapUISpecial", line_no, #new_line + 1, 1)
    new_line = new_line .. prefix .. " "

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

function Scopes:render(session)
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
  local render_state = require("dapui.render").init_state()
  self:render_scopes(render_state)
  self.render_receiver(render_state)
end

function Scopes:toggle_reference(line)
  local current_ref = self.line_variable_map[line]
  if not current_ref then
    return
  end
  local session = require("dap").session()
  if not session then
    print("No active session to query")
    return
  end
  if self.expanded_references[current_ref] ~= EXPAND_STATE.COLLAPSED then
    self.expanded_references[current_ref] = EXPAND_STATE.COLLAPSED
    self:render(session)
  else
    self.expanded_references[current_ref] = EXPAND_STATE.TO_EXPAND
    session:request(
      "variables",
      {variablesReference = current_ref},
      function()
        -- nvim-dap requires a callback function to trigger other listeners
      end
    )
  end
end

local M = {}
local listener_id = "dapui_scopes"

M.name = "DAP Scopes"

M.buf_settings = {
  filetype = "dapui_scopes"
}

function M.on_open(buf, render_receiver)
  Scopes.render_receiver = render_receiver
  vim.api.nvim_buf_set_keymap(
    buf,
    "n",
    Scopes.config.mappings.expand_variable,
    "<Cmd>lua require('dapui.scopes').toggle_reference()<CR>",
    {}
  )
  Scopes:render(require("dap").session())
end

function M.toggle_reference()
  Scopes:toggle_reference(vim.fn.line("."))
end

function M.setup(user_config)
  Scopes.config = user_config
  local dap = require("dap")
  dap.listeners.after.variables[listener_id] = function(session, err, response, request)
    if not err then
      Scopes.references[request.variablesReference] = response.variables
      Scopes:render(session)
    end
  end

  dap.listeners.after.scopes[listener_id] = function(session, err, response)
    if not err then
      local references = {}
      for _, scope in pairs(response.scopes) do
        references[scope.variablesReference] = scope.variables
      end
      Scopes.scopes = vim.tbl_extend("force", Scopes.scopes, response.scopes)
      Scopes.references = vim.tbl_extend("force", Scopes.references, references)
      Scopes:render(session)
    end
  end

  dap.listeners.after.event_stopped[listener_id] = function(session)
    Scopes:render(session)
  end
end

return M
