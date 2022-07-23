local config = require("dapui.config")

local M = {}

local api = vim.api

function M.round(num)
  if num < math.floor(num) + 0.5 then
    return math.floor(num)
  else
    return math.ceil(num)
  end
end

function M.is_uri(path)
  local scheme = path:match("^([a-z]+)://.*")
  if scheme then
    return true
  else
    return false
  end
end

---@param cb fun(session: table)
function M.with_session(cb, fail_cb)
  local session = require("dap").session()
  if session then
    cb(session)
  elseif fail_cb then
    fail_cb()
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

function M.jump_to_frame(frame, session, set_frame)
  if set_frame then
    session:_frame_set(frame)
    return
  end
  local line = frame.line
  local column = frame.column
  local source = frame.source
  if not source then
    return
  end

  if (source.sourceReference or 0) > 0 then
    local buf = vim.api.nvim_create_buf(false, true)
    session:request("source", { sourceReference = source.sourceReference }, function(response, err)
      if err then
        return
      end
      if not response.body.content then
        vim.notify("No source available for frame", "WARN")
        return
      end
      vim.api.nvim_buf_set_lines(buf, 0, 0, true, vim.split(response.body.content, "\n"))
      M.open_buf(buf, line, column)
      vim.api.nvim_buf_set_option(buf, "bufhidden", "delete")
      vim.api.nvim_buf_set_option(buf, "modifiable", false)
    end)
    return
  end

  if not source.path then
    vim.notify("No source available for frame", "WARN")
  end

  local path = source.path

  if not column or column == 0 then
    column = 1
  end

  local bufnr =
    vim.uri_to_bufnr(M.is_uri(path) and path or vim.uri_from_fname(vim.fn.fnamemodify(path, ":p")))
  vim.fn.bufload(bufnr)
  M.open_buf(bufnr, line, column)
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
    vim.api.nvim_buf_set_keymap(buffer, "n", key, func, { noremap = true })
  end
end

function M.pretty_name(path)
  if M.is_uri(path) then
    path = vim.uri_to_fname(path)
  end
  return vim.fn.fnamemodify(path, ":t")
end

function M.pop(tbl, key, default)
  local val = default
  if tbl[key] then
    val = tbl[key]
    tbl[key] = nil
  end
  return val
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
  local max_length = config.render().max_type_length
  if not max_length then
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

return M
