local config = require("dapui.config")
local util = require("dapui.util")


local _GROUP = vim.api.nvim_create_augroup("NvimDapUiDisassembly", { clear = false})


local function _get_height(buffer)
  return vim.api.nvim_win_get_height(window)
end


local function _get_spacing(count)
  return string.rep("\t", count)
end


local function _get_column_aligned(instructions)
  local address_max = 1
  local byte_max = 1
  local instruction_max = 1

  for _, instruction in ipairs(instructions)
  do
    local address_count = #instruction.address

    if address_count > address_max then
      address_max = address_count
    end

    local byte_count = #instruction.instructionBytes

    if byte_count > byte_max then
      byte_max = byte_count
    end

    local instruction_count = #instruction.instruction

    if instruction_count > instruction_max then
      instruction_max = instruction_count
    end
  end

  local spacing = ""

  if config.disassembly.instruction_spacing >= 1 then
    -- Prevent an invalid configuration from accidentally breaking things
    -- Note: Maybe this can be pre-validated so we don't have to check here?
    spacing = _get_spacing(config.disassembly.instruction_spacing)
  end

  local column_justified_template = string.format(
    "%%-%ss%%s%%-%ss%%s%%-%ss\n",
    address_max,
    byte_max,
    instruction_max
  )

  local output = {}

  for _, instruction in ipairs(instructions) do
    table.insert(
      output,
      string.format(
        column_justified_template,
        instruction.address,
        spacing,
        instruction.instructionBytes,
        spacing,
        instruction.instruction
      )
    )
  end

  return output
end


local function _get_lines(instructions)
  if config.disassembly.column_aligned then
    return _get_column_aligned(instructions)
  end

  local spacing = ""

  if config.disassembly.instruction_spacing >= 1 then
    -- Prevent an invalid configuration from accidentally breaking things
    -- Note: Maybe this can be pre-validated so we don't have to check here?
    --
    spacing = _get_spacing(config.disassembly.instruction_spacing)
  end

  local lines = {}

  for _, instruction in ipairs(instructions) do
    table.insert(
      lines,
      string.format(
        "%s%s%s%s%s\n",
        instruction.address,
        spacing,
        instruction.instructionBytes,
        spacing,
        instruction.instruction
      )
    )
  end
end


---@param client dapui.DAPClient
---@param send_ready function
return function(client, buffer, send_ready)
  -- Force a redraw of the window whenever its size has changed or the cursor is moving
  vim.api.nvim_create_autocmd(
    "WinScrolled",
    {
      buffer = buffer,
      callback = function()
        send_ready()
      end,
      group = _GROUP,
    }
  )

  local on_exit = function()
    -- Remove auto-commands as needed
    vim.api.nvim_clear_autocmds({buffer=buffer, group=_GROUP})
  end

  client.listen.scopes(send_ready)  -- TODO: Maybe should just a more generic event?
  client.listen.disassemble(send_ready)
  client.listen.disconnect(on_exit)
  client.listen.exited(on_exit)
  client.listen.terminated(on_exit)

  return {
    ---@param canvas dapui.Canvas
    render = function(canvas)
      if client.session == nil
      then
        -- client.session will be nil when exiting so we stop before that can error.
        return
      end

      if not client.session.capabilities.supportsDisassembleRequest then
        util.notify(
          "Debug server doesn't support disassembly requests.",
          vim.log.levels.WARN
        )

        return
      end

      local memory_reference = client.session.current_frame["instructionPointerReference"]

      if memory_reference == nil then
        util.notify(
          "Disassembly could not get the starting memory address.",
          vim.log.levels.WARN
        )

        return
      end

      --- @source https://microsoft.github.io/debug-adapter-protocol/specification#Requests_Disassemble
      --- @type dapui.types.DisassembleResponse
      local response
      local success

      local window = vim.fn.bufwinid(buffer)
      local height = vim.api.nvim_win_get_height(window)
      local count = height * 2
      local offset = -1 * height

      success, response = pcall(
        client.request.disassemble,
        {
          -- TODO: Finish this part
          memoryReference=memory_reference,
          instructionOffset=offset,
          instructionCount=count,
          offset=0,
          resolveSymbols=true,
        }
      )

      if not success then
        util.notify(
          "Disassembly could not be found. Cannot continue.",
          vim.log.levels.WARN
        )

        return
      end

      if response == nil then
        util.notify(
          "Invalid disassembly response. Cannot continue.",
          vim.log.levels.WARN
        )

        return
      end

      local lines = _get_lines(response.instructions)

      for _, line in ipairs(lines) do
        canvas:write(line)
      end

      -- Move the cursor after the canvas has finished drawing to the buffer
      local cursor_line = height + 1
      vim.schedule(function() vim.api.nvim_win_set_cursor(window, {cursor_line, 0}) end)
    end
  }
end
