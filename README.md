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
tray which sits on the top or bottom of the screen. Both of these can contain
any of the available elements.

Elements can also be displayed temporarily in a floating window.

You can supply an object to the `require("dapui").setup()` function to
configure the elements.

Default settings:

```lua
require("dapui").setup({
  icons = {
    expanded = "▾",
    collapsed = "▸"
  },
  mappings = {
    -- Use a table to apply multiple mappings
    expand = {"<CR>", "<2-LeftMouse>"},
    open = "o",
    remove = "d",
    edit = "e",
  },
  sidebar = {
    open_on_start = true,
    elements = {
      -- You can change the order of elements in the sidebar
      "scopes",
      "breakpoints",
      "stacks",
      "watches"
    },
    width = 40,
    position = "left" -- Can be "left" or "right"
  },
  tray = {
    open_on_start = true,
    elements = {
      "repl"
    },
    height = 10,
    position = "bottom" -- Can be "bottom" or "top"
  },
  floating = {
    max_height = nil, -- These can be integers or a float between 0 and 1.
    max_width = nil   -- Floats will be treated as percentage of your screen.
  }
})
```

### Variable Scopes

![image](https://user-images.githubusercontent.com/24252670/126842891-c5175f13-5eb7-4d0a-9dae-620c4d31448a.png)

Element ID: `scopes`

Displays the available scopes and variables within them.

Mappings:

- `expand`: Toggle showing any children of variable.

### Threads and Stack Frames

![image](https://user-images.githubusercontent.com/24252670/126843106-5dce09dc-49d0-4aaa-ba98-fd8f17b31414.png)

Element ID: `stacks`

Displays the running threads and their stack frames.

Mappings:

- `open`: Jump to a place within the stack frame.

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
- `edit`: Edit an expression.

### Breakpoints

![image](https://user-images.githubusercontent.com/24252670/126843577-361645e4-6265-40eb-86dc-d6607512a15e.png)

Element ID: `breakpoints`

List all breakpoints currently set.

Mappings:

- `open`: Jump to the location the breakpoint is set

### REPL

Element ID: `repl`

The REPL provided by nvim-dap.

## Usage

To get started simply call the setup method on startup, optionally providing
custom settings.

```lua
require("dapui").setup()
```

nvim-dap-ui will add hooks to nvim-dap to open the sidebar and tray whenever
you start a debugging session, and close when the session is finished.

You can manually open, close and toggle the windows with corresponding functions:

```lua
require("dapui").open()
require("dapui").close()
require("dapui").toggle()
```

Each of the functions optionally takes either `"sidebar"` or `"tray"` as an
argument to only change the specified component.

### Floating Elements

For elements that are not opened in the tray or sidebar, you can open them in a
floating window.

![image](https://user-images.githubusercontent.com/24252670/126844102-8789effb-4276-4599-afe6-a074b019c38d.png)

```lua
require("dapui").float_element(<element ID>)
```

If you do not provide an element ID, you will be queried to select one.

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

