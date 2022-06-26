# nvim-dap-ui

This is still early stage software. Bugs are expected and there may be breaking
changes!

## Introduction

A UI for [nvim-dap](https://github.com/mfussenegger/nvim-dap) which provides a
good out of the box configuration.

![Preview](https://user-images.githubusercontent.com/24252670/126842672-de9c6b78-eec2-4187-b48e-977686ec4080.png)

## Installation

Install with your favourite package manager alongside nvim-dap

[**dein**](https://github.com/Shougo/dein.vim):

```vim
call dein#add("mfussenegger/nvim-dap")
call dein#add("rcarriga/nvim-dap-ui")
```

[**vim-plug**](https://github.com/junegunn/vim-plug)

```vim
Plug 'mfussenegger/nvim-dap'
Plug 'rcarriga/nvim-dap-ui'
```

[packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use { "rcarriga/nvim-dap-ui", requires = {"mfussenegger/nvim-dap"} }
```

## Configuration

nvim-dap-ui is built on the idea of "elements". These elements are windows
which provide different features.

The UI is split between a sidebar which sits on the side of the screen, and a
tray which sits on the bottom of the screen by default. Both of these can
contain any of the available elements and the position of each can be changed
to any side of the screen.

Elements can also be displayed temporarily in a floating window.

You can supply an object to the `require("dapui").setup()` function to
configure the elements.

Default settings:

```lua
require("dapui").setup({
  icons = { expanded = "▾", collapsed = "▸" },
  mappings = {
    -- Use a table to apply multiple mappings
    expand = { "<CR>", "<2-LeftMouse>" },
    open = "o",
    remove = "d",
    edit = "e",
    repl = "r",
    toggle = "t",
  },
  -- Expand lines larger than the window
  -- Requires >= 0.7
  expand_lines = vim.fn.has("nvim-0.7"),
  -- Layouts define sections of the screen to place windows.
  -- The position can be "left", "right", "top" or "bottom".
  -- The size specifies the height/width depending on position. It can be an Int
  -- or a Float. Integer specifies height/width directly (i.e. 20 lines/columns) while
  -- Float value specifies percentage (i.e. 0.3 - 30% of available lines/columns)
  -- Elements are the elements shown in the layout (in order).
  -- Layouts are opened in order so that earlier layouts take priority in window sizing.
  layouts = {
    {
      elements = {
      -- Elements can be strings or table with id and size keys.
        { id = "scopes", size = 0.25 },
        "breakpoints",
        "stacks",
        "watches",
      },
      size = 40, -- 40 columns
      position = "left",
    },
    {
      elements = {
        "repl",
        "console",
      },
      size = 0.25, -- 25% of total lines
      position = "bottom",
    },
  },
  floating = {
    max_height = nil, -- These can be integers or a float between 0 and 1.
    max_width = nil, -- Floats will be treated as percentage of your screen.
    border = "single", -- Border style. Can be "single", "double" or "rounded"
    mappings = {
      close = { "q", "<Esc>" },
    },
  },
  windows = { indent = 1 },
  render = {
    max_type_length = nil, -- Can be integer or nil.
  }
})
```

### Variable Scopes

![image](https://user-images.githubusercontent.com/24252670/126842891-c5175f13-5eb7-4d0a-9dae-620c4d31448a.png)

Element ID: `scopes`

Displays the available scopes and variables within them.

Mappings:

- `edit`: Edit the value of a variable
- `expand`: Toggle showing any children of variable.
- `repl`: Send variable to REPL

### Threads and Stack Frames

![image](https://user-images.githubusercontent.com/24252670/126843106-5dce09dc-49d0-4aaa-ba98-fd8f17b31414.png)

Element ID: `stacks`

Displays the running threads and their stack frames.

Mappings:

- `open`: Jump to a place within the stack frame.
- `toggle`: Toggle displaying [subtle](https://microsoft.github.io/debug-adapter-protocol/specification#Types_StackFrame) frames

### Watch Expressions

![image](https://user-images.githubusercontent.com/24252670/126843390-4e1575d8-9d7d-4f43-8680-094cfe9eae63.png)

Element ID: `watches`

Allows creation of expressions to watch the value of in the context of the
current frame.
This uses a prompt buffer for input. To enter a new expression, just enter
insert mode and you will see a prompt appear. Press enter to submit

Mappings:

- `expand`: Toggle showing the children of an expression.
- `remove`: Remove the watched expression.
- `edit`: Edit an expression or set the value of a child variable.
- `repl`: Send expression to REPL

### Breakpoints

![image](https://user-images.githubusercontent.com/24252670/126843577-361645e4-6265-40eb-86dc-d6607512a15e.png)

Element ID: `breakpoints`

List all breakpoints currently set.

Mappings:

- `open`: Jump to the location the breakpoint is set
- `toggle`: Enable/disable the selected breakpoint

### REPL

Element ID: `repl`

The REPL provided by nvim-dap.

### Console

Element ID: `console`

The console window used by nvim-dap for the integrated terminal.

## Usage

To get started simply call the setup method on startup, optionally providing
custom settings.

```lua
require("dapui").setup()
```

You can open, close and toggle the windows with corresponding functions:

```lua
require("dapui").open()
require("dapui").close()
require("dapui").toggle()
```

Each of the functions optionally takes either `"sidebar"` or `"tray"` as an
argument to only change the specified component.

You can use nvim-dap events to open and close the windows automatically (`:help dap-extensions`)

```lua
local dap, dapui = require("dap"), require("dapui")
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end
```

### Floating Elements

For elements that are not opened in the tray or sidebar, you can open them in a
floating window.

![image](https://user-images.githubusercontent.com/24252670/126844102-8789effb-4276-4599-afe6-a074b019c38d.png)

```lua
require("dapui").float_element(<element ID>, <optional settings>)
```

If you do not provide an element ID, you will be queried to select one.

The optional settings can included the following keys:

- `width: number` Width of the window
- `height: number` Height of the window
- `enter: boolean` Enter the floating window

Call the same function again while the window is open and the cursor will jump
to the floating window. The REPL will automatically jump to the floating
window on open.

### Evaluate Expression

For a one time expression evaluation, you can call a hover window to show a value

![image](https://user-images.githubusercontent.com/24252670/126844454-691d691c-4550-46fe-89dc-25e1e9681545.png)

```lua
require("dapui").eval(<expression>)
```

If an expression is not provided it will use the word under the cursor, or if in
visual mode, the currently highlighted text.
You can define a visual mapping like so

```vim
vnoremap <M-k> <Cmd>lua require("dapui").eval()<CR>
```

Call the same function again while the window is open to jump to the eval window.

The same mappings as the variables element apply within the hover window.
