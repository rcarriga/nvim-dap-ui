local config = require("dapui.config")
local util = require("dapui.util")


local _GROUP = vim.api.nvim_create_augroup("NvimDapUiDisassembly", { clear = false})

--- @class vim.loop.timer
--- @field start fun(self: vim.loop.timer, timeout: integer, start: integer, function: fun(...))
---     A function that, when called, starts in `start` milliseconds,
---     stops at `timeout`, and all the while calls `function`.

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


--- Copy `data` to a new table.
---
--- @param data table<any> The data to copy.
--- @return table<any> # The copied data.
---
local function _shallow_copy(data)
  local output = {}

  for key, value in pairs(data)
  do
    output[key] = value
  end

  return output
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

  --- @type table<integer, integer>?
  local previous_cursor = nil
  local cursor_adjustment_needed = false
  local mute_autocommands = false
  local should_reset_the_cursor = false

  -- Force a redraw of the window whenever its size has changed or the cursor is moving
  vim.api.nvim_create_autocmd(
    "WinScrolled",
    {
      buffer = buffer,
      callback = function()
        if mute_autocommands
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

          previous_cursor = vim.api.nvim_win_get_cursor(window)
          cursor_adjustment_needed = true
        elseif top_line >= (vim.api.nvim_buf_line_count(buffer) - height)
        then
          -- We're at the botton page, request a new page below the cursor
          instruction_counter.offset = math.min(0, instruction_counter.offset + height)
          instruction_counter.count = instruction_counter.count + height  -- Get increasingly more

          previous_cursor = vim.api.nvim_win_get_cursor(window)
          cursor_adjustment_needed = true
          send_ready()
        end
      end,
      group = _GROUP,
    }
  )

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

  local _offset_current_cursor = _debounce_leading(
    function(height)
      local window = vim.fn.bufwinid(buffer)

      --- @diagnostic disable-next-line: param-type-mismatch
      local cursor = _shallow_copy(previous_cursor)
      cursor[1] = cursor[1] - height
      mute_autocommands = true
      vim.api.nvim_win_set_cursor(window, cursor)
      mute_autocommands = false
    end,
    200  -- TODO: Tune this value, later
  )

  return {
    render = function(canvas)
      local _cursor_adjustment_needed = cursor_adjustment_needed
      cursor_adjustment_needed = false

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

      if instruction_counter.count == nil or instruction_counter.offset == nil
      then
        -- Initialize the instructions for the first time
        instruction_counter.count = height * 2
        instruction_counter.offset = -1 * height
      end

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

        return
      end

      if response == nil then
        util.notify(
          "Invalid disassembly response. Cannot continue.",
          vim.log.levels.WARN
        )

        return
      end

      -- TODO: Consider writing a single blob of text
      for _, line in ipairs(_get_lines(response.instructions))
      do
        canvas:write(line)
      end

      if _cursor_adjustment_needed
      then
          _offset_current_cursor(height)
      -- TODO: Finish this
      -- elseif should_reset_the_cursor
      -- then
      --   local cursor_row = height + 1
      --   -- Move the cursor after the canvas has finished drawing to the buffer
      --   vim.schedule(
      --     function()
      --       should_reset_the_cursor = false
      --       mute_autocommands = true
      --       vim.api.nvim_win_set_cursor(window, {cursor_row, 0})
      --       mute_autocommands = false
      --     end
      --   )
      end
    end
  }
end
