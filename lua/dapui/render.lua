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

  function Render:render_buffer(win, buffer)
    local lines = self.lines
    local matches = self.matches
    vim.fn["setbufvar"](buffer, "&modifiable", 1)
    vim.fn["clearmatches"](win)
    vim.api.nvim_buf_set_lines(vim.fn["bufnr"](buffer), 0, #lines, false, lines)
    local last_line = vim.fn["line"]("$")
    if last_line > #lines then
      vim.api.nvim_buf_set_lines(vim.fn["bufnr"](buffer), #lines, last_line, false, {})
    end
    for _, match in pairs(matches) do
      vim.fn["matchaddpos"](match[1], {match[2]}, 10, -1, {window = win})
    end
    vim.fn["setbufvar"](buffer, "&modifiable", 0)
  end

  return Render
end


return M
