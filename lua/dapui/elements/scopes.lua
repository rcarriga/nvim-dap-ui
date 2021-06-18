local M = {}

local Element = {}
local config = require("dapui.config")

local function reset_state()
  Element.render_receiver = {}
  Element.scopes = {}
  Element.references = {}
  Element.line_variable_map = {}
  Element.expanded_references = {}
end

reset_state()

local function var_from_ref_path(ref_path)
  local var_path_elems = vim.split(ref_path, "/")
  return tonumber(var_path_elems[#var_path_elems])
end

function Element:reference_prefix(ref_path)
  if vim.endswith(ref_path, "/0") then
    return " "
  end
  return config.icons()[self.expanded_references[ref_path] and "expanded" or "collapsed"]
end

function Element:render_variables(ref_path, render_state, indent, expanded)
  expanded[ref_path] = true
  local var_path_elems = vim.split(ref_path, "/")
  local var_ref = tonumber(var_path_elems[#var_path_elems])
  for _, variable in pairs(self.references[var_ref] or {}) do
    local line_no = render_state:length() + 1
    local var_reference_path = ref_path .. "/" .. variable.variablesReference
    self.line_variable_map[line_no] = var_reference_path

    local new_line = string.rep(" ", indent)
    local prefix = self:reference_prefix(var_reference_path)
    render_state:add_match("DapUIDecoration", line_no, #new_line + 1, 1)
    new_line = new_line .. prefix .. " "

    render_state:add_match("DapUIVariable", line_no, #new_line + 1, #variable.name)
    new_line = new_line .. variable.name

    if #(variable.type or "") > 0 then
      new_line = new_line .. " "
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

    if self.expanded_references[var_reference_path] and not expanded[var_reference_path] then
      self:render_variables(var_reference_path, render_state, indent + config.windows().indent, expanded)
    end
  end
end

function Element:render_scopes(render_state)
  local expanded = {}
  for i, scope in pairs(self.scopes or {}) do
    render_state:add_match("DapUIScope", render_state:length() + 1, 1, #scope.name)
    render_state:add_line(scope.name .. ":")
    self:render_variables(tostring(scope.variablesReference), render_state, config().windows.indent, expanded)
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

function M.toggle_reference()
  local line = vim.fn.line(".")
  local current_ref_path = Element.line_variable_map[line]
  if not current_ref_path then
    return
  end
  local session = require("dap").session()
  if not session then
    print("No active session to query")
    return
  end
  if Element.expanded_references[current_ref_path] then
    Element.expanded_references[current_ref_path] = nil
    Element:render(session)
  else
    Element.expanded_references[current_ref_path] = true
    local var_path_elems = vim.split(current_ref_path, "/")
    local current_ref = tonumber(var_path_elems[#var_path_elems])
    session:request(
      "variables",
      {variablesReference = current_ref},
      function()
        -- nvim-dap requires a callback function to trigger other listeners
      end
    )
  end
end

local listener_id = "dapui_scopes"

M.name = "DAP Scopes"

function M.on_open(buf, render_receiver)
  vim.api.nvim_buf_set_option(buf, "filetype", "dapui_scopes")
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  pcall(vim.api.nvim_buf_set_name, buf, M.name)
  Element.render_receiver[buf] = render_receiver
  require("dapui.util").apply_mapping(
    config.mappings().expand,
    "<Cmd>lua require('dapui.elements.scopes').toggle_reference()<CR>",
    buf
  )
  Element:render(require("dap").session())
end

function M.on_close(info)
  Element.render_receiver[info.buffer] = nil
end

function M.setup()
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
      local to_refresh = {}

      for ref_path, _ in pairs(Element.expanded_references) do
        to_refresh[#to_refresh + 1] = var_from_ref_path(ref_path)
      end

      for _, ref in pairs(to_refresh) do
        session:request(
          "variables",
          {variablesReference = ref},
          function()
          end
        )
      end

      Element.scopes = vim.tbl_extend("force", Element.scopes, response.scopes)
      Element.references = vim.tbl_extend("force", Element.references, references)
      Element:render(session)
    end
  end
  dap.listeners.after.event_terminated[listener_id] = function()
    reset_state()
  end
end

return M
