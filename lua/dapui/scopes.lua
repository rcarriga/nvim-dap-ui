local M = {}
local listener_id = "dapui_scopes"

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
  scopes = {},
  references = {},
  line_variable_map = {},
  expanded_references = {}
}

vim.cmd("hi default link DapUIVariable Normal")
vim.cmd("hi default DapUIScope guifg=#A9FF68")
vim.cmd("hi default DapUIType guifg=#D484FF")
vim.cmd("hi default DapUISpecial guifg=#00f1f5")

function Scopes:update_state(session)
  local scopes = session.current_frame.scopes
  local expanded = {}
  local references = {}
  for _, scope in pairs(scopes) do
    expanded[scope.variablesReference] = true
    references[scope.variablesReference] = scope.variables
  end
  self.scopes = vim.tbl_extend("force", self.scopes, scopes)
  self.references = vim.tbl_extend("force", self.references, references)
  self.line_variable_map = self.line_variable_map
  self.expanded_references = vim.tbl_extend("force", self.expanded_references, expanded)
end

function Scopes:reference_prefix(ref, render_state)
  if ref == 0 then
    return "  "
  elseif render_state.expanded[ref] then
    return "↺ "
  end
  return self.expanded_references[ref] and "⯆ " or "⯈ "
end

function Scopes:render_variables(reference, render_state, indent)
  render_state.expanded[reference] = true
  local refs = {}
  for _, v in pairs(self.references[reference] or {}) do
    refs[#refs + 1] = v.variablesReference
  end
  for _, variable in pairs(self.references[reference] or {}) do
    self.line_variable_map[#render_state.lines + 1] = variable.variablesReference

    local new_line = string.rep(" ", indent)
    local prefix = self:reference_prefix(variable.variablesReference, render_state)
    render_state.matches[#render_state.matches + 1] = {"DapUISpecial", {#render_state.lines + 1, #new_line + 1, 2}}
    new_line = new_line .. prefix

    render_state.matches[#render_state.matches + 1] = {
      "DapUIVariable",
      {#render_state.lines + 1, #new_line + 1, #variable.name}
    }
    new_line = new_line .. variable.name

    if #variable.type > 0 then
      new_line = new_line .. " ("
      render_state.matches[#render_state.matches + 1] = {
        "DapUIType",
        {#render_state.lines + 1, #new_line + 1, #variable.type}
      }
      new_line = new_line .. variable.type .. ")"
    end

    if #variable.value > 0 then
      new_line = new_line .. ": "
      local value_start = #new_line
      new_line = new_line .. variable.value

      for i, line in pairs(vim.split(new_line, "\n")) do
        if i > 1 then
          line = string.rep(" ", value_start - 2) .. line
        end
        render_state.lines[#render_state.lines + 1] = line
      end
    else
      render_state.lines[#render_state.lines + 1] = new_line
    end

    if self.expanded_references[variable.variablesReference] and not render_state.expanded[variable.variablesReference] then
      render_state = self:render_variables(variable.variablesReference, render_state, indent + 1)
    end
  end
  return render_state
end

function Scopes:render()
  local win = vim.fn["bufwinnr"](M.buffer_info.name)
  if win >= 0 then
    local render_state = {
      lines = {},
      matches = {},
      expanded = {}
    }
    for i, scope in pairs(self.scopes or {}) do
      render_state.matches[#render_state.matches + 1] = {"DapUIScope", {#render_state.lines + 1, 1, #scope.name}}
      render_state.lines[#render_state.lines + 1] = scope.name .. ":"
      render_state = self:render_variables(scope.variablesReference, render_state, 1)
      if i < #self.scopes then
        render_state.lines[#render_state.lines + 1] = ""
      end
    end
    vim.fn["setbufvar"](M.buffer_info.name, "&modifiable", 1)
    vim.fn["clearmatches"](win)
    vim.api.nvim_buf_set_lines(vim.fn["bufnr"](M.buffer_info.name), 0, #render_state.lines, false, render_state.lines)
    local last_line = vim.fn["line"]("$")
    if last_line > #render_state.lines then
      vim.api.nvim_buf_set_lines(vim.fn["bufnr"](M.buffer_info.name), #render_state.lines, last_line, false, {})
    end
    for _, match in pairs(render_state.matches) do
      vim.fn["matchaddpos"](match[1], {match[2]}, 10, -1, {window = win})
    end
    vim.fn["setbufvar"](M.buffer_info.name, "&modifiable", 0)
  end
end

local function fill_reference(session, buf_state, reference)
  session:request(
    "variables",
    {variablesReference = reference},
    function(_, response)
      if response then
        buf_state.references[reference] = response.variables
      end
    end
  )
end

function Scopes:refresh(session)
  if not session or not session.current_frame then
    return
  end
  self:update_state(session)
  self:render()
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
  if Scopes.expanded_references[current_ref] then
    Scopes.expanded_references[current_ref] = nil
    Scopes:refresh(session)
  else
    Scopes.expanded_references[current_ref] = true
    fill_reference(session, Scopes, current_ref)
  end
end

function M.setup()
  local dap = require("dap")
  dap.listeners.after.variables[listener_id] = function(session)
    Scopes:refresh(session)
  end

  dap.listeners.after.event_stopped[listener_id] = function(session)
    Scopes:refresh(session)
  end
end

return M
