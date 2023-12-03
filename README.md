- Need error recovery when the user goes too far up or down
- Consider a different action other than <Enter>


- Make PR
     - Copying the line is weird. Why?
     - Ask about the weird coloring if it can be turned off
     - Moving the cursor left/right in a line looks weird. Fix?


- New action for displaying memory under cursor
  - Use treesitter to get the node under the cursor
  - Read its address
  - Do basically - lua require("my_custom.utilities.memory_test").dump_memory("0x0000000000400584")
  - Make a pop-up, maybe?
  - Make sure this window keeps a reference to that memory even when scopes change
- Disassembly HEX viewer
 - https://github.com/microsoft/debug-adapter-protocol/issues/348
- https://github.com/RaafatTurki/hex.nvim/issues/15
 - Could be a good idea to have a hex viewer
 - /home/selecaoone/repositories/vimspector/python3/vimspector/code.py


--- Fix this bug
    If error - stepping outside of the code window breaks things
    Debug adapter reported a frame at line 8 column 1, but: Cursor position outside buffer. Ensure executable is up2date and if using a source mapping ensure it is correct


https://github.com/microsoft/debug-adapter-protocol/issues/200
:lua require("dap").session():request("readMemory", {memoryReference="0x0000000000400015", count=1000}, function(error, result
) print(vim.inspect(result)) end)

lua require("dap").session():request("readMemory", {memoryReference="0x0000000000400015", count=1000}, function(error, result
) print(vim.inspect(result)) end)

lua require("dap").session():request("readMemory", {memoryReference="0x7fffffffcf78", count=1024}, function(error, result) print(vim.inspect(result)) end)























When scrolling down far, you get this error

```
Rendering failed: .../bundle/nvim-dap-ui/lua/dapui/components/disassembly.lua:67: attempt to get length of field 'instructionB
ytes' (a nil value)
stack traceback:
        ...sonal/.config/nvim/bundle/nvim-dap-ui/lua/dapui/util.lua:17: in function '__len'
        .../bundle/nvim-dap-ui/lua/dapui/components/disassembly.lua:67: in function '_get_alignment_template'
        .../bundle/nvim-dap-ui/lua/dapui/components/disassembly.lua:116: in function '_get_lines'
        .../bundle/nvim-dap-ui/lua/dapui/components/disassembly.lua:476: in function 'render'
        ...im/bundle/nvim-dap-ui/lua/dapui/elements/disassembly.lua:28: in function 'render'
        ...im/bundle/nvim-dap-ui/lua/dapui/elements/disassembly.lua:16: in function <...im/bundle/nvim-dap-ui/lua/dapui/elemen
ts/disassembly.lua:15>
        [C]: in function 'xpcall'
        ...sonal/.config/nvim/bundle/nvim-dap-ui/lua/dapui/util.lua:16: in function <...sonal/.config/nvim/bundle/nvim-dap-ui/
lua/dapui/util.lua:12>
```

Have a fallback in mind




# nvim-dap-ui

## Introduction

A UI for [nvim-dap](https://github.com/mfussenegger/nvim-dap) which provides a
good out of the box configuration.

![preview](https://user-images.githubusercontent.com/24252670/191198389-a1321363-c0f1-4ff1-b663-ab1350d2b393.png)

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

[**packer.nvim**](https://github.com/wbthomason/packer.nvim)

```lua
use { "rcarriga/nvim-dap-ui", requires = {"mfussenegger/nvim-dap"} }
```

## Configuration

nvim-dap-ui is built on the idea of "elements". These elements are windows
which provide different features.

Elements are grouped into layouts which can be placed on any side of the screen.
There can be any number of layouts, containing whichever elements desired.

Elements can also be displayed temporarily in a floating window.

See `:h dapui.setup()` for configuration options and defaults

It is highly recommended to use [neodev.nvim](https://github.com/folke/neodev.nvim) to enable type checking for nvim-dap-ui to get
type checking, documentation and autocompletion for all API functions.

```lua
require("neodev").setup({
  library = { plugins = { "nvim-dap-ui" }, types = true },
  ...
})
```

The default icons use [codicons](https://github.com/microsoft/vscode-codicons).
It's recommended to use this [fork](https://github.com/ChristianChiarulli/neovim-codicons) which fixes alignment issues
for the terminal. If your terminal doesn't support font fallback and you need to have icons included in your font, you can patch it via [Font Patcher](https://github.com/ryanoasis/nerd-fonts#option-8-patch-your-own-font). 
There is a simple step by step guide [here](https://github.com/mortepau/codicons.nvim#how-to-patch-fonts).

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
- `position: string` Position of floating window. `center` or `nil`

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
