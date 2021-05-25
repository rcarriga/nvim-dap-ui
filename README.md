# nvim-dap-ui

This is still early stage software. Bugs are expected and there may be breaking
changes!

## Introduction

A UI for [nvim-dap](https://github.com/mfussenegger/nvim-dap) which provides a
good out of the box configuration.

![Preview](https://user-images.githubusercontent.com/24252670/114298796-f8db2d80-9aaf-11eb-95cd-2ea758d85b2b.png)

## Installation

Install with your favourite package manager alongside nvim-dap

[**dein**](https://github.com/Shougo/dein.vim):

```vim
call dein#add("mfussenegger/nvim-dap")
call dein#add("rcarriga/nvim-dap-ui")
```

[**vim-plug**](https://github.com/junegunn/vim-plug)

```vim
Plug "mfussenegger/nvim-dap"
Plug "rcarriga/nvim-dap-ui"
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
    expanded = "⯆",
    collapsed = "⯈",
    circular = "↺"
  },
  mappings = {
    -- Use a table to apply multiple mappings
    expand = {"<CR>", "<2-LeftMouse>"},
    open = "o",
    remove = "d",
    edit = "e",
  },
  sidebar = {
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
    elements = {
      "repl"
    },
    height = 10,
    position = "bottom" -- Can be "bottom" or "top"
  }
  floating = {
    max_height = nil, -- These can be integers or a float between 0 and 1.
    max_width = nil   -- Floats will be treated as percentage of your screen.
  }
})
```

### Variable Scopes

![image](https://user-images.githubusercontent.com/24252670/114298911-8cacf980-9ab0-11eb-9bc1-e0f1b23cd0a2.png)

Element ID: `scopes`

Displays the available scopes and variables within them.

Mappings:

- `expand`: Toggle showing any children of variable.

### Threads and Stack Frames

![image](https://user-images.githubusercontent.com/24252670/114298952-bbc36b00-9ab0-11eb-9f9b-347a9089edd9.png)

Element ID: `stacks`

Displays the running threads and their stack frames.

Mappings:

- `open`: Jump to a place within the stack frame.

### Watch Expressions

![image](https://user-images.githubusercontent.com/24252670/114298997-fcbb7f80-9ab0-11eb-8cb8-a78f5a46e710.png)

Element ID: `watches`

Allows creation of expressions to watch the value of in the context of the
stack frame they are defined in.
This uses a prompt buffer for input. To enter a new expression, just enter
insert mode and you will see a prompt appear. Press enter to submit

Mappings:

- `open`: Jump to the stack frame the expression was defined in.
- `expand`: Toggle the value and frame position of the expression.
- `remove`: Remove the watched expression.
- `edit`: Edit an expression

### Breakpoints

![image](https://user-images.githubusercontent.com/24252670/119557290-e4b96a00-bd97-11eb-9c97-ebaa847b1b7c.png)

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

### Floating Elements

For elements that are not opened in the tray or sidebar, you can open them in a
floating window.

![image](https://user-images.githubusercontent.com/24252670/114299177-da763180-9ab1-11eb-8437-8ddf7d0f1577.png)

```lua
require("dapui").float_element(<element ID>)
```

If you do not provide an element ID, you will be queried to select one.

Call the same function again while the window is open and the cursor will jump
to the floating window. The REPL will automatically jump to the floating
window on open.

### Evaluate Expression

For a one time expression evaluation, you can call a hover window to show a value

![image](https://user-images.githubusercontent.com/24252670/114299131-a438b200-9ab1-11eb-86ad-9be1fc592e51.png)

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
