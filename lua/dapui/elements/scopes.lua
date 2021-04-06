local Element = {
  render_receiver = {},
  config = {},
  scopes = {},
  references = {},
  line_variable_map = {},
  expanded_references = {}
}

function Element:reference_prefix(ref, expanded)
  if ref == 0 then
    return " "
  elseif expanded[ref] then
    return self.config.icons.circular
  end
  return self.config.icons[self.expanded_references[ref] and "expanded" or "collapsed"]
end

function Element:render_variables(reference, render_state, indent, expanded)
  expanded[reference] = true
  for _, variable in pairs(self.references[reference] or {}) do
    local line_no = render_state:length() + 1
    self.line_variable_map[line_no] = variable.variablesReference

    local new_line = string.rep(" ", indent)
    local prefix = self:reference_prefix(variable.variablesReference, expanded)
    render_state:add_match("DapUISpecial", line_no, #new_line + 1, 1)
    new_line = new_line .. prefix .. " "

    render_state:add_match("DapUIVariable", line_no, #new_line + 1, #variable.name)
    new_line = new_line .. variable.name

    if #(variable.type or "") > 0 then
      new_line = new_line .. ": "
      render_state:add_match("DapUIType", line_no, #new_line + 1, #variable.type)
      new_line = new_line .. variable.type
    end

    if #(variable.value or "") > 0 then
      new_line = new_line .. " = "
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

    if self.expanded_references[variable.variablesReference] and not expanded[variable.variablesReference] then
      self:render_variables(variable.variablesReference, render_state, indent + 1, expanded)
    end
  end
end

function Element:render_scopes(render_state)
  local expanded = {}
  for i, scope in pairs(self.scopes or {}) do
    render_state:add_match("DapUIScope", render_state:length() + 1, 1, #scope.name)
    render_state:add_line(scope.name .. ":")
    self:render_variables(scope.variablesReference, render_state, 1, expanded)
    if i < #self.scopes then
      render_state:add_line()
    end
  end
end

function Element:should_render(session)
  return session and session.current_frame and not vim.tbl_isempty(self.render_receiver)
end

function Element:render(session)
  if not self:should_render(session) then
    return
  end
  local render_state = require("dapui.render").init_state()
  self:render_scopes(render_state)
  for buf, reciever in pairs(self.render_receiver) do
    vim.api.nvim_buf_set_option(buf, "modifiable", true)
    reciever(render_state)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
  end
end

function _G.scopes_toggle_reference()
  local line = vim.fn.line(".")
  local current_ref = Element.line_variable_map[line]
  if not current_ref then
    return
  end
  local session = require("dap").session()
  if not session then
    print("No active session to query")
    return
  end
  if Element.expanded_references[current_ref] then
    Element.expanded_references[current_ref] = nil
    Element:render(session)
  else
    Element.expanded_references[current_ref] = true
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

function M.on_open(buf, render_receiver)
  vim.api.nvim_buf_set_option(buf, "filetype", "dapui_scopes")
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  pcall(vim.api.nvim_buf_set_name, buf, M.name)
  Element.render_receiver[buf] = render_receiver
  vim.api.nvim_buf_set_keymap(
    buf,
    "n",
    Element.config.mappings.expand_variable,
    "<Cmd>call v:lua.scopes_toggle_reference()<CR>",
    {}
  )
  Element:render(require("dap").session())
end

function M.on_close(info)
  Element.render_receiver[info.buffer] = nil
end

function M.setup(user_config)
  Element.config = user_config

  vim.cmd("hi default link DapUIVariable Normal")
  vim.cmd("hi default DapUIScope guifg=#A9FF68")
  vim.cmd("hi default DapUIType guifg=#D484FF")
  vim.cmd("hi default DapUISpecial guifg=#00F1F5")

  local dap = require("dap")
  dap.listeners.after.variables[listener_id] = function(session, err, response, request)
    if not err then
      Element.references[request.variablesReference] = response.variables
      Element:render(session)
    end
  end

  dap.listeners.after.scopes[listener_id] = function(session, err, response)
    if not err then
      local references = {}
      for _, scope in pairs(response.scopes) do
        references[scope.variablesReference] = scope.variables
      end
      Element.scopes = vim.tbl_extend("force", Element.scopes, response.scopes)
      Element.references = vim.tbl_extend("force", Element.references, references)
      Element:render(session)
    end
  end

  dap.listeners.after.event_stopped[listener_id] = function(session)
    Element:render(session)
  end
end

return M
