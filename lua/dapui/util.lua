local M = {}

local api = vim.api

function M.is_uri(path)
  local scheme = path:match("^([a-z]+)://.*")
  if scheme then
    return true
  else
    return false
  end
end

local function open_buf(bufnr, line, column)
  for _, win in pairs(api.nvim_tabpage_list_wins(0)) do
    if api.nvim_win_get_buf(win) == bufnr then
      api.nvim_win_set_cursor(win, {line, column - 1})
      api.nvim_set_current_win(win)
      return
    end
  end

  for _, win in pairs(api.nvim_tabpage_list_wins(0)) do
    local winbuf = api.nvim_win_get_buf(win)
    if api.nvim_buf_get_option(winbuf, "buftype") == "" then
      local bufchanged, _ = pcall(api.nvim_win_set_buf, win, bufnr)
      if bufchanged then
        api.nvim_win_set_cursor(win, {line, column - 1})
        api.nvim_set_current_win(win)
        return
      end
    end
  end
end

function M.jump_to_frame(frame, session)
  local line = frame.line
  local column = frame.column
  local source = frame.source
  if not source then
    return
  end

  if (source.sourceReference or 0) > 0 then
    local buf = vim.api.nvim_create_buf(false, true)
    session:request(
      "source",
      {sourceReference = source.sourceReference},
      function(response, err)
        if err then
          return
        end
        if not response.body.content then
          print("No source available for frame")
          return
        end
        vim.api.nvim_buf_set_lines(buf, 0, 0, true, vim.split(response.body.content, "\n"))
        open_buf(buf, line, column)
        vim.api.nvim_buf_set_option(buf, "bufhidden", "delete")
        vim.api.nvim_buf_set_option(buf, "modifiable", false)
      end
    )
    return
  end

  if not source.path then
    print("No source available for frame")
  end

  local path = source.path

  if not column or column == 0 then
    column = 1
  end

  local bufnr = vim.uri_to_bufnr(M.is_uri(path) and path or vim.uri_from_fname(path))
  vim.fn.bufload(bufnr)
  open_buf(bufnr, line, column)
end

function M.get_selection(start, finish)
  local start_line, start_col = start[2], start[3]
  local finish_line, finish_col = finish[2], finish[3]
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
    vim.api.nvim_buf_set_keymap(buffer, "n", key, func, {})
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

return M
