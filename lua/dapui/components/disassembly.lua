local config = require("dapui.config")
local util = require("dapui.util")


local _GROUP = vim.api.nvim_create_augroup("NvimDapUiDisassembly", { clear = false})
local _SELECTION_HIGHLIGHT_GROUP = "NvimDapUiDisassemblyHighlightLine"
local _VIRTUAL_SELECTION = vim.api.nvim_create_namespace("NvimDapUiDisassemblyVirtualSelection")

--- @class vim.loop.timer
--- @field start fun(self: vim.loop.timer, timeout: integer, start: integer, function: fun(...))
---     A function that, when called, starts in `start` milliseconds,
---     stops at `timeout`, and all the while calls `function`.

--- Figure out the spacing needed for every column in `instructions`.
---
--- Each instruction address has potentially varying lengths of memory addresses,
--- memory bytes, and Assembly instruction text. However most developers enjoy
--- reading the text like this:
---
--- 0x0004 85 ba 00        some assembly command
--- 0x0008 87 aa 11 34 77  another assembly command
---
--- Use this function to produce a format string that will align that text.
---
--- @param instructions dapui.types.DisassembledInstruction[]
---     Each of the instructions to query for individual element lengths.
--- @return string
---     # The recommended template that will provided aligned columns.
---
local function _get_alignment_template(instructions)
  local address_max = 1

  -- Note: To prevent any user disruption, we assume 8, 2-letter byte addresses
  -- (8bytes * 2letters) + (7spaces) == 23
  --
  -- In short, it's a reasonable default to minimize disruption
  --
  local byte_max = 23

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

  return string.format(
    "%%-%ss%%s%%-%ss%%s%%-%ss\n",
    address_max,
    byte_max,
    instruction_max
  )
end


--- Repeat the "\t" character `count` number of times.
---
--- @param count integer The number of times to repeat. Should be 1-or-more.
--- @return string # The generated "\t\t\t" text.
---
local function _get_spacing(count)
  return string.rep("\t", count)
end


--- Get the disassembly text from `instructions`, aligned by-column.
---
--- @param instructions dapui.types.DisassembledInstruction[]
---     Each of the instructions to query for individual element lengths.
--- @return string[]
---     # The raw disassembly lines to display, later.
---
local function _get_column_aligned(instructions)
  local spacing = ""

  if config.disassembly.instruction_spacing >= 1 then
    -- Prevent an invalid configuration from accidentally breaking things
    -- Note: Maybe this can be pre-validated so we don't have to check here?
    spacing = _get_spacing(config.disassembly.instruction_spacing)
  end

  local output = {}
  local column_justified_template = _get_alignment_template(instructions)

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


local function _get_instructions(client, memory_reference, instruction_counter)
  --- @source https://microsoft.github.io/debug-adapter-protocol/specification#Requests_Disassemble
  --- @type dapui.types.DisassembleResponse
  local response
  local success

  success, response = pcall(
    client.request.disassemble,
    {
      -- TODO: Finish this part. Add more spec details
      memoryReference=memory_reference,
      instructionOffset=instruction_counter.offset,
      instructionCount=instruction_counter.count,
      offset=0,
      resolveSymbols=true,
    }
  )

  if not success then
    util.notify(
      "Disassembly could not be found. Cannot continue.",
      vim.log.levels.WARN
    )

    return nil
  end

  if response == nil then
    util.notify(
      "Invalid disassembly response. Cannot continue.",
      vim.log.levels.WARN
    )

    return nil
  end

  return response.instructions
end


--- Get the disassembly text from `instructions`.
---
--- @param instructions dapui.types.DisassembledInstruction[]
---     Each of the instructions to query for individual element lengths.
--- @return string[]
---     # The raw disassembly lines to display, later.
---
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

  local output = {}

  for _, instruction in ipairs(instructions) do
    table.insert(
      output,
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

  return output
end


--- Parse `text` for a memory address.
---
--- @param text string Some disassembly. e.g. "0x000000000040056f	48 83 ec 20	sub    $0x20,%rsp".
--- @return string? # The found address, if any. e.g. "0x000000000040056f".
---
local function _get_memory_address(text)
  return string.match(text, "^0x%x+")
end


--- Find the Disassembly memory address that's located at the current `window` cursor.
---
--- Note:
---     It's expected that `window` and `buffer` correspond to the same data.
---
--- @param window integer A 0-or-more identifier to the window cursor to grab from.
--- @param buffer integer A 0-or-more identifier for the lines of text to query with.
--- @return string? # The found address, if any. e.g. "0x000000000040056f".
---
local function _get_memory_address_at_current_cursor(window, buffer)
  local buffer = buffer or vim.api.nvim_win_get_buf(window)
  local cursor = vim.api.nvim_win_get_cursor(window)
  local row = cursor[1]
  local line = vim.api.nvim_buf_get_lines(buffer, row - 1, row, false)[1]

  return _get_memory_address(line)
end


local function _get_memory_address_at_current_instruction(window, buffer)
end


local function _get_session_frame(client)
  if client.session == nil
  then
    -- client.session will be nil when exiting so we stop before that can error.
    return nil
  end

  if not client.session.capabilities.supportsDisassembleRequest then
    util.notify(
      "Debug server doesn't support disassembly requests.",
      vim.log.levels.WARN
    )

    return nil
  end

  local memory_reference = client.session.current_frame["instructionPointerReference"]

  if memory_reference ~= nil then
    return memory_reference
  end

  util.notify(
    "Disassembly could not get the starting memory address.",
    vim.log.levels.WARN
  )

  return nil
end


--- Debounce a function and prefer the first call.
---
--- If the debounced function is called repeatedly in the span of `timeout`,
--- ignore all but the first call. This is helpful to prevent spammy autocommands
--- from triggering too often.
---
--- @source https://gist.github.com/runiq/31aa5c4bf00f8e0843cd267880117201#debouncing-on-the-leading-edge
---
--- @param function_ fun(...)
---     A function to call or defer.
--- @param timeout number
---     Timeout in millisecond.
--- @return function, vim.loop.timer
---     # The debounced function and timer. Remember to call `timer:close()` at the end
---     or you will leak memory!
---
local function _debounce_leading(function_, timeout)
  --- @type vim.loop.timer
  local timer = vim.loop.new_timer()

  local running = false

  local function wrapped(...)
    timer:start(
      timeout,
      0,
      function()
        running = false
      end
    )

    if not running then
      running = true
      pcall(vim.schedule_wrap(function_), select(1, ...))
    end
  end

  return wrapped, timer
end


local function _highlight_buffer_line(window, buffer, row)
  local row = row or vim.api.nvim_win_get_cursor(window)[1]

  vim.api.nvim_buf_set_extmark(
      buffer,
      _VIRTUAL_SELECTION,
      row - 1,
      0,
      {
          end_line = row,
          end_col = 0,
          hl_group = _SELECTION_HIGHLIGHT_GROUP,
          hl_mode = "blend",
      }
  )
end


local function _initialize_counters(instruction_counter, height)
  if instruction_counter.count == nil or instruction_counter.offset == nil
  then
    -- Initialize the instructions for the first time
    instruction_counter.count = height * 2
    instruction_counter.offset = -1 * height
  end
end


--- Force `window`'s cursor to point to the line that contains `address`.
---
--- @param window integer A 0-or-more window identifier whose cursor may be moved.
--- @param cursor_address string Some memory address to look for. e.g. `"0x000000000040056f"`.
---
local function _save_and_restore_cursor(window, cursor_address)
  local buffer = vim.api.nvim_win_get_buf(window)
  local disassembly_lines = vim.api.nvim_buf_get_lines(
    buffer,
    0,
    vim.api.nvim_buf_line_count(buffer),
    false
  )

  local found_row = nil
  for row, line in ipairs(disassembly_lines)
  do
    local address = _get_memory_address(line)

    if address == cursor_address
    then
      found_row = row

      break
    end
  end

  if found_row == nil
  then
    return
  end

  local old_cursor = vim.api.nvim_win_get_cursor(window)
  local old_column = old_cursor[2]
  local new_cursor = {found_row, old_column}

  vim.api.nvim_win_set_cursor(window, new_cursor)
end


--- Configure `buffer` so it can display in `client` when buffer-rendering is requested.
---
--- @param client dapui.DAPClient
---     The current DAP session's controller class.
--- @param send_ready function
---     A callback that will trigger `render()`, which updates the display of
---     the nvim-dap-ui Disassembly buffer
--- @return dapui.types.RenderableComponent
---
return function(client, buffer, send_ready)
  -- TODO: Add type info here
  local instruction_counter = {
    offset = nil,
    count = nil,
  }

  local function _get_computed_instruction_line()
    -- The current frame is the actual instruction line. The offset
    -- is relative to this line. So to get the current line, we must get
    -- a 0-or-more offset value (if the offset is negative, make it positive).
    -- Then `+ 1` because our offset is 0-or-more but cursor rows start at 1, not 0.
    --
    return math.max(0, -1 * instruction_counter.offset) + 1
  end

  local cursor_adjustment_needed = false
  local mute_line_adjustments = false
  local should_reset_the_cursor = false

  -- Force a redraw of the window whenever its size has changed or the cursor is moving
  vim.api.nvim_create_autocmd(
    "WinScrolled",
    {
      buffer = buffer,
      callback = function()
        if mute_line_adjustments
        then
          return
        end

        local window = vim.fn.bufwinid(buffer)
        local top_line = vim.fn.getwininfo(window)[1].topline
        local height = vim.api.nvim_win_get_height(window)

        if top_line == 1
        then
          -- We're at the top of the buffer, request another page above the cursor
          instruction_counter.offset = instruction_counter.offset - height
          instruction_counter.count = instruction_counter.count + height  -- Get increasingly more

          cursor_adjustment_needed = true
          send_ready()
        elseif top_line >= (vim.api.nvim_buf_line_count(buffer) - height)
        then
          -- We're at the botton page, request a new page below the cursor
          instruction_counter.offset = math.min(0, instruction_counter.offset + height)
          instruction_counter.count = instruction_counter.count + height  -- Get increasingly more

          cursor_adjustment_needed = true
          send_ready()
        end
      end,
      group = _GROUP,
    }
  )

  -- TODO: Add configuration option from "Visual" to something else
  vim.api.nvim_set_hl(0, _SELECTION_HIGHLIGHT_GROUP, {link="Visual"})

  local on_exit = function()
    -- Remove auto-commands as needed
    vim.api.nvim_clear_autocmds({buffer=buffer, group=_GROUP})
  end

  local on_reset = function()
    should_reset_the_cursor = true
    send_ready()
  end

  client.listen.scopes(on_reset)  -- TODO: Maybe `scopes` should just a more generic event?
  client.listen.disassemble(send_ready)
  client.listen.disconnect(on_exit)
  client.listen.exited(on_exit)
  client.listen.terminated(on_exit)

  local _reset_cursor = _debounce_leading(
    function(window, buffer, cursor_row)
      should_reset_the_cursor = false
      mute_line_adjustments = true
      vim.api.nvim_win_set_cursor(window, {cursor_row, 0})
      _highlight_buffer_line(window, buffer, cursor_row)
      mute_line_adjustments = false
    end,
    200  -- TODO: Tune this value, later
  )

  return {
    render = function(canvas)
      local _cursor_adjustment_needed = cursor_adjustment_needed
      cursor_adjustment_needed = false  -- TODO: Double check if this stuff is useful

      local memory_reference = _get_session_frame(client)

      if memory_reference == nil then
        return
      end

      local window = vim.fn.bufwinid(buffer)
      local height = vim.api.nvim_win_get_height(window)

      _initialize_counters(instruction_counter, height)

      local instructions = _get_instructions(client, memory_reference, instruction_counter)

      if instructions == nil then
        return
      end

      -- @type string?
      local cursor_address = nil

      if _cursor_adjustment_needed
      then
        cursor_address = _get_memory_address_at_current_cursor(window, buffer)
      end

      vim.api.nvim_buf_clear_namespace(buffer, _VIRTUAL_SELECTION, 0, -1)

      -- TODO: Consider writing a single blob of text
      for _, line in ipairs(_get_lines(instructions))
      do
        canvas:write(line)
      end

      if _cursor_adjustment_needed
      then
        if cursor_address ~= nil
        then
          -- Save and restore the cursor row position
          vim.schedule(
            function()
              _save_and_restore_cursor(window, cursor_address)
              local current_instruction_line = _get_computed_instruction_line()
              _highlight_buffer_line(window, buffer, current_instruction_line)
            end
          )
        else
          vim.api.nvim_err_writeln(
            "nvim-dap-ui: Could not find an address at the current cursor. "
            .. "Disassembly refresh may not work as expected."
          )
        end
      elseif should_reset_the_cursor
      then
        -- Set the cursor to the disassembly line that matches the source code line
        instruction_counter.count = height * 2
        instruction_counter.offset = -1 * height
        local current_instruction_line = _get_computed_instruction_line()
        _reset_cursor(window, buffer, current_instruction_line)
      end
    end
  }
end
