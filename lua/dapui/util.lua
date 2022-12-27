local config = require("dapui.config")
local async = require("dapui.async")

local M = {}

local api = vim.api

---@return function
function M.create_render_loop(render)
  local render_cond = async.control.Condvar.new()
  local pending = false

  async.run(function()
    while true do
      if not pending then
        render_cond:wait()
      end
      pending = false
      xpcall(render, function(msg)
        local traceback = debug.traceback(msg, 1)
        M.notify(("Rendering failed: %s"):format(traceback), vim.log.levels.WARN)
      end)
      async.util.sleep(10)
    end
  end)

  return function()
    pending = true
    render_cond:notify_all()
  end
end

function M.create_buffer(name, options)
  local buf = async.api.nvim_create_buf(true, true)
  options = vim.tbl_extend("keep", options or {}, {
    modifiable = false,
  })
  async.api.nvim_buf_set_name(buf, name)
  for opt, value in pairs(options) do
    async.api.nvim_buf_set_option(buf, opt, value)
  end
  return buf
end

function M.round(num)
  if num < math.floor(num) + 0.5 then
    return math.floor(num)
  else
    return math.ceil(num)
  end
end

function M.notify(msg, level, opts)
  return vim.notify(
    msg,
    level or vim.log.levels.INFO,
    vim.tbl_extend("keep", opts or {}, {
      title = "nvim-dap-ui",
      icon = "",
      on_open = function(win)
        vim.api.nvim_buf_set_option(vim.api.nvim_win_get_buf(win), "filetype", "markdown")
      end,
    })
  )
end

function M.is_uri(path)
  local scheme = path:match("^([a-z]+)://.*")
  if scheme then
    return true
  else
    return false
  end
end

function M.open_buf(bufnr, line, column)
  for _, win in pairs(api.nvim_tabpage_list_wins(0)) do
    if api.nvim_win_get_buf(win) == bufnr then
      if line then
        api.nvim_win_set_cursor(win, { line, (column or 1) - 1 })
      end
      api.nvim_set_current_win(win)
      return
    end
  end

  for _, win in pairs(api.nvim_tabpage_list_wins(0)) do
    local winbuf = api.nvim_win_get_buf(win)
    if api.nvim_buf_get_option(winbuf, "buftype") == "" then
      local bufchanged, _ = pcall(api.nvim_win_set_buf, win, bufnr)
      if bufchanged then
        if line then
          api.nvim_win_set_cursor(win, { line, (column or 1) - 1 })
        end
        api.nvim_set_current_win(win)
        return
      end
    end
  end
end

function M.get_selection(start, finish)
  local start_line, start_col = start[2], start[3]
  local finish_line, finish_col = finish[2], finish[3]

  if start_line > finish_line or (start_line == finish_line and start_col > finish_col) then
    start_line, start_col, finish_line, finish_col = finish_line, finish_col, start_line, start_col
  end

  local lines = vim.fn.getline(start_line, finish_line)
  if #lines == 0 then
    return
  end
  lines[#lines] = string.sub(lines[#lines], 1, finish_col)
  lines[1] = string.sub(lines[1], start_col)
  return lines
end

function M.apply_mapping(mappings, func, buffer)
  for _, key in pairs(mappings) do
    if type(func) ~= "string" then
      vim.api.nvim_buf_set_keymap(buffer, "n", key, "", { noremap = true, callback = func })
    else
      vim.api.nvim_buf_set_keymap(buffer, "n", key, func, { noremap = true })
    end
  end
end

function M.pretty_name(path)
  if M.is_uri(path) then
    path = vim.uri_to_fname(path)
  end
  return vim.fn.fnamemodify(path, ":t")
end

function M.format_error(error)
  if vim.tbl_isempty(error.body or {}) then
    return error.message
  end
  if not error.body.error then
    return error.body.message
  end
  local formatted = error.body.error.format
  for name, val in pairs(error.body.error.variables or {}) do
    formatted = string.gsub(formatted, "{" .. name .. "}", val)
  end
  return formatted
end

function M.partial(func, ...)
  local args = { ... }
  return function(...)
    local final = vim.list_extend(args, { ... })
    return func(unpack(final))
  end
end

function M.send_to_repl(expression)
  local repl_win = vim.fn.bufwinid("[dap-repl]")
  if repl_win == -1 then
    M.float_element("repl")
    repl_win = vim.fn.bufwinid("[dap-repl]")
  end
  api.nvim_set_current_win(repl_win)
  vim.cmd("normal i" .. expression)
end

function M.float_element(elem_name)
  local line_no = vim.fn.screenrow()
  local col_no = vim.fn.screencol()
  local position = { line = line_no, col = col_no }
  local elem = require("dapui.elements." .. elem_name)
  return require("dapui.windows").open_float(elem, position, elem.float_defaults or {})
end

function M.render_type(maybe_type)
  if not maybe_type then
    return ""
  end
  local max_length = config.render.max_type_length
  if not max_length or max_length == -1 then
    return maybe_type
  end
  if max_length == 0 then
    return ""
  end
  if vim.str_utfindex(maybe_type) <= max_length then
    return maybe_type
  end

  local byte_length = vim.str_byteindex(maybe_type, max_length)
  return string.sub(maybe_type, 1, byte_length) .. "..."
end

---@param value_start integer
---@param value string
---@return string[]
function M.format_value(value_start, value)
  local formatted = {}
  local max_lines = config.render.max_value_lines
  local i = 0
  --- Use gsplit instead of split because adapters can returns very long values
  --- and we want to avoid creating thousands of substrings that we won't use.
  for line in vim.gsplit(value, "\n") do
    i = i + 1

    if max_lines and i > max_lines then
      local line_count = 1
      for _ in value:gmatch("\n") do
        line_count = line_count + 1
      end

      formatted[i - 1] = formatted[i - 1] .. ((" ... [%s more lines]"):format(line_count - i + 1))
      break
    end
    if i > 1 then
      line = string.rep(" ", value_start - 2) .. line
    end
    formatted[i] = line
  end
  return formatted
end

return M
