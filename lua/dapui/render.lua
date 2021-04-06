local M = {}

function M.init_state()
  local Render = {
    lines = {},
    matches = {}
  }

  function Render:add_line(line)
    self.lines[#self.lines + 1] = line or ""
  end

  function Render:add_match(group, line, start_col, length)
    self.matches[#self.matches + 1] = {
      group,
      {line, start_col, length}
    }
  end

  function Render:length()
    return #self.lines
  end

  function Render:width()
    local width = 0
    for _, line in pairs(self.lines) do
      width = width < #line and #line or width
    end
    return width
  end

  function Render:render_buffer(buffer)
    if buffer < 0 then
      return false
    end
    local win = vim.fn.bufwinnr(buffer)
    if win == -1 then
      return false
    end
    local lines = self.lines
    local matches = self.matches
    vim.fn["clearmatches"](win)
    vim.api.nvim_buf_set_lines(buffer, 0, #lines, false, lines)
    local last_line = vim.fn.getbufinfo(buffer)[1].linecount
    if last_line > #lines then
      vim.api.nvim_buf_set_lines(buffer, #lines, last_line, false, {})
    end
    for _, match in pairs(matches) do
      vim.fn["matchaddpos"](match[1], {match[2]}, 10, -1, {window = win})
    end
    return true
  end

  return Render
end

return M
