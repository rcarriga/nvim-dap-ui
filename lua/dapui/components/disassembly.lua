--- The implementation for the "DAP Disassembly" canvas.
---
--- @module 'dapui.components.disassembly'
---

local config = require("dapui.config")
local util = require("dapui.util")


local _GROUP = vim.api.nvim_create_augroup("NvimDapUiDisassembly", { clear = false})
local _SELECTION_HIGHLIGHT_GROUP = "DapUIDisassemblyHighlightLine"
local _VIRTUAL_SELECTION = vim.api.nvim_create_namespace("NvimDapUiDisassemblyVirtualSelection")

---@class _DiassemblyInstructionCounter
---    Packed data that is needed in order to draw/redraw disassembly instructions.
---@field count? integer
---    A 1-or-more value indicating how many lines of assembly to request.
---@field offset? integer
---    A 0-or-more relative value indicating where to start looking for assembly lines.

---@class _DisassemblyWindowState
---    Control the refresh, draw, and other behaviors of a Disassembly Buffer
---@field adjust_direction_down boolean?
---    A tri-state variable.
---    - `nil` means "do nothing"
---    - `true` means "offset the cursor downwards"
---    - `false` means "offset the cursor upwards"
---@field should_reset_the_cursor boolean
---    If `false`, do nothing. If `true`, the next time the Disassembly Buffer
---    is re-rendered, the Disassembly cursor will sync to the current stack frame.

---@class vim.loop.timer
---@field start fun(self: vim.loop.timer, timeout: integer, start: integer, function: fun(...))
---    A function that, when called, starts in `start` milliseconds,
---    stops at `timeout`, and all the while calls `function`.


--- Check if `instructions` has any invalid portions.
---
--- This function typically returns `true` whenever `instruction_counter.count`
--- is too high. When that happens, the `instructions` has at least one element
--- that has incomplete contents.
---
---@param instructions dapui.types.DisassembledInstruction[]
---    Each of the instructions to query for individual element lengths.
---@return boolean
---    If `instructions` is complete, return `true. Otherwise, return `false`.
---
local function _is_valid(instructions)
  for _, instruction in ipairs(instructions) do
    if instruction.instructionBytes == nil then
      return false
    end
  end

  return true
end

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
---@param instructions dapui.types.DisassembledInstruction[]
---    Each of the instructions to query for individual element lengths.
---@return string
---    The recommended template that will provided aligned columns.
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

  for _, instruction in ipairs(instructions) do
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
---@param count integer The number of times to repeat. Should be 1-or-more.
---@return string # The generated "\t\t\t" text.
---
local function _get_spacing(count)
  return string.rep("\t", count)
end


--- Get the disassembly text from `instructions`, aligned by-column.
---
---@param instructions dapui.types.DisassembledInstruction[]
---    Each of the instructions to query for individual element lengths.
---@return string
---    The raw disassembly lines to display, later.
---
local function _get_column_aligned(instructions)
  local spacing = ""

  if config.disassembly.instruction_spacing >= 1 then
    -- Prevent an invalid configuration from accidentally breaking things
    -- Note: Maybe this can be pre-validated so we don't have to check here?
    spacing = _get_spacing(config.disassembly.instruction_spacing)
  end

  local output = ""
  local column_justified_template = _get_alignment_template(instructions)

  for _, instruction in ipairs(instructions) do
    output = output .. string.format(
      column_justified_template,
      instruction.address,
      spacing,
      instruction.instructionBytes,
      spacing,
      instruction.instruction
    )
  end

  return output
end


--- Disassemble at `memory_reference` and get the instructions back.
---
---@param client dapui.DAPClient
---    The current DAP session's controller class.
---@param memory_reference string
---    The memory address used to anchor the disassembly.
---    Important: This is *not* always the starting line of the disassembly.
---    That depends on `instruction_counter`.
---@param instruction_counter _DiassemblyInstructionCounter
---    A "number of disassembly lines to get" and a relative "offset" to start from.
---    The `memory_reference` + "offset" determines the 1st line of assembly returned.
---@return dapui.types.DisassembledInstruction[]?
---    The found instructions, if any.
---
local function _get_instructions(client, memory_reference, instruction_counter)
  ---@type dapui.types.DisassembleResponse
  local response
  local success

  ---@source https://microsoft.github.io/debug-adapter-protocol/specification#Requests_Disassemble
  success, response = pcall(
    client.request.disassemble,
    {
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
---@param instructions dapui.types.DisassembledInstruction[]
---    Each of the instructions to query for individual element lengths.
---@return string
---    The raw disassembly lines to display, later.
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

  local output = ""

  for _, instruction in ipairs(instructions) do
    output = output .. string.format(
      "%s%s%s%s%s\n",
      instruction.address,
      spacing,
      instruction.instructionBytes,
      spacing,
      instruction.instruction
    )
  end

  return output
end


--- Find the current memory address of an active DAP `client`.
---
---@param client dapui.DAPClient
---    The current DAP session's controller class.
---@return string?
---    The found memory address, if any.
---
local function _get_session_frame(client)
  if client.session == nil then
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
---@source https://gist.github.com/runiq/31aa5c4bf00f8e0843cd267880117201#debouncing-on-the-leading-edge
---
---@param function_ fun(...)
---    A function to call or defer.
---@param timeout number
---    Timeout in millisecond.
---@return function, vim.loop.timer
---    The debounced function and timer. Remember to call `timer:close()` at the end
---    or you will leak memory!
---
local function _debounce_leading(function_, timeout)
  ---@type vim.loop.timer
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


--- Highlight the Disassembly instruction that is about to be executed.
---
---@param buffer integer
---    A 0-or-more Neovim Buffer ID which will be modified by this function.
---@param row integer
---    A 1-or-more value indicating the cursor line to highlight.
---
local function _highlight_current_instruction(buffer, row)
  vim.fn.sign_place(
    _VIRTUAL_SELECTION,
    "",
    "DapUIDisassemblyCurrentLineSign",
    buffer,
    { lnum = row }
  )
end


--- Set-up `instruction_counter` for the first time using `height`, if needed.
---
---@param instruction_counter _DiassemblyInstructionCounter
---    The packed data to modify if it has not be set before.
---@param height integer
---    A 1-or-more window vertical height indicator.
---
local function _initialize_counters(instruction_counter, height)
  if instruction_counter.count == nil or instruction_counter.offset == nil then
    -- Initialize the instructions for the first time
    instruction_counter.count = height * 2
    instruction_counter.offset = -1 * height
  end
end


--- Add auto-commands for the Disassembly `buffer`.
---
--- If the user scrolls the cursor in the current buffer, there's a chance that more
--- DAP Disassemble requests will be made (it depends on how close the cursor is to
--- the top ot bottom of the buffer).
---
---@source
---    - https://github.com/mfussenegger/nvim-dap/issues/331#issuecomment-1801296947
---    - https://github.com/puremourning/vimspector/blob/66617adda22d29c60ec2ee9bcb854329352ada80/python3/vimspector/disassembly.py#L229-L260
---
---@param buffer integer
---    A 0-or-more Neovim Buffer ID which will be modified by this function.
---@param state _DisassemblyWindowState
---    A secondary Disassembly Buffer controller object. Used to determine things
---    like whether or not the auto-commands should run and how.
---@param send_ready function()
---    The callback which, when called, triggers the Disassembly Buffer to redraw.
---
local function _setup_auto_commands(buffer, state, instruction_counter, send_ready)
  -- Force a redraw of the window whenever its size has changed or the cursor is moving
  vim.api.nvim_create_autocmd(
    "WinScrolled",
    {
      buffer = buffer,
      callback = function()
        local window = vim.fn.bufwinid(buffer)
        local top_line = vim.fn.getwininfo(window)[1].topline
        local height = vim.api.nvim_win_get_height(window)

        if top_line == 1 then
          -- We're at the top of the buffer, request another page above the cursor
          instruction_counter.offset = instruction_counter.offset - height
          instruction_counter.count = instruction_counter.count + height  -- Get increasingly more

          state.adjust_direction_down = true
          send_ready()
        elseif top_line >= (vim.api.nvim_buf_line_count(buffer) - height) then
          -- We're at the botton page, request a new page below the cursor
          instruction_counter.offset = math.min(0, instruction_counter.offset + height)
          instruction_counter.count = instruction_counter.count + height  -- Get increasingly more

          state.adjust_direction_down = false
          send_ready()
        end
      end,
      group = _GROUP,
    }
  )
end


--- Configure `buffer` so it can display in `client` when buffer-rendering is requested.
---
---@param client dapui.DAPClient
---    The current DAP session's controller class.
---@param send_ready function
---    A callback that will trigger `render()`, which updates the display of
---    the nvim-dap-ui Disassembly Buffer
---@return dapui.types.RenderableComponent
---
return function(client, buffer, send_ready)
  ---@type _DiassemblyInstructionCounter
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

  ---@type _DisassemblyWindowState
  local state = {
    adjust_direction_down = nil,
    should_reset_the_cursor = false
  }

  _setup_auto_commands(buffer, state, instruction_counter, send_ready)

  local on_exit = function()
    -- Remove auto-commands as needed
    vim.api.nvim_clear_autocmds({buffer=buffer, group=_GROUP})
  end

  local on_reset = function()
    state.should_reset_the_cursor = true
    send_ready()
  end

  client.listen.scopes(on_reset)  -- TODO: Maybe `scopes` should just a more generic event?
  client.listen.disassemble(send_ready)
  client.listen.disconnect(on_exit)
  client.listen.exited(on_exit)
  client.listen.terminated(on_exit)

  local _force_cursor = _debounce_leading(
    function(window, cursor_row)
      vim.api.nvim_win_set_cursor(window, {cursor_row, 0})
    end,
    20  -- A small enough number that won't risk triggering `_force_cursor` 2+ times
  )

  local _reset_cursor = _debounce_leading(
    function(window, buffer_, cursor_row)
      state.should_reset_the_cursor = false
      vim.api.nvim_win_set_cursor(window, {cursor_row, 0})
      _highlight_current_instruction(buffer_, cursor_row)
    end,
    20  -- A small enough number that won't risk triggering `_reset_cursor` 2+ times
  )

  ---@type _DiassemblyInstructionCounter
  local previous_instruction_counter = {
    count = nil,
    offset = nil,
  }

  return {
    render = function(canvas)
      -- Reset any state that needs to be reset
      local _adjust_direction_down = state.adjust_direction_down
      state.adjust_direction_down = nil

      local memory_reference = _get_session_frame(client)

      if memory_reference == nil then
        return
      end

      local window = vim.fn.bufwinid(buffer)

      if window == -1 then
        return
      end

      local height = vim.api.nvim_win_get_height(window)

      _initialize_counters(instruction_counter, height)

      local instructions = _get_instructions(client, memory_reference, instruction_counter)

      if instructions == nil or not _is_valid(instructions) then
        -- Important: we `- height` because `_is_valid` tends to only be true when
        -- the count is too high. By backing off a bit, we ensure that the window
        -- will still be in-bounds.
        --
        instruction_counter.count = previous_instruction_counter.count - height
        instruction_counter.offset = previous_instruction_counter.offset
        instructions = _get_instructions(client, memory_reference, instruction_counter)
      else
        previous_instruction_counter.count = instruction_counter.count
        previous_instruction_counter.offset = instruction_counter.offset
      end

      -- Set-up the canvas for writing
      canvas:write(_get_lines(instructions))

      -- Now that the canvas is updated, set up per-line mappings
      local current_instruction_line = _get_computed_instruction_line()

      for line = 1, canvas:length() do
        canvas:add_mapping(
          "expand",
          function()
            _force_cursor(window, current_instruction_line)
          end,
          {line=line}
        )
      end

      -- Since the canvas updated, the user's current cursor may be out of date. Fix it
      if _adjust_direction_down ~= nil then
        ---@type integer
        local offset

        if _adjust_direction_down then
          offset = height
        else
          offset = -1 * height
        end

        local current_row = vim.api.nvim_win_get_cursor(window)[1]
        local new_row = current_row + offset

        -- Important: You need to schedule this or the line will not highlight correctly
        vim.schedule(
          function()
            vim.api.nvim_win_set_cursor(window, {new_row, 0})
            _highlight_current_instruction(buffer, current_instruction_line)
          end
        )
      elseif state.should_reset_the_cursor then
        instruction_counter.count = height * 2
        instruction_counter.offset = -1 * height
        _reset_cursor(window, buffer, current_instruction_line)
      end
    end
  }
end
