# diff-edit.nvim

A lightweight Neovim plugin for side-by-side diff editing with hunk-level operations. Eliminates the complexity of vimdiff and provides intuitive keymaps for diff operations.

## Features

- 🔀 Side-by-side diff view with synchronized scrolling
- 🎯 Navigate between hunks with simple keymaps
- ⚡ Apply changes at the hunk level (left-to-right or right-to-left)
- 🎨 Visual highlighting for added, changed, and deleted lines
- 🔄 Automatic diff recalculation on buffer changes
- 📝 File names displayed in winbar

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "sontixyou/diff-edit.nvim",
  opts = {}
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "sontixyou/diff-edit.nvim",
  config = function()
    require("diff-edit").setup()
  end
}
```

## Usage

Open two files in diff mode:

```vim
:DiffEdit path/to/file_a.txt path/to/file_b.txt
```

Or from Lua:

```lua
require("diff-edit").open("path/to/file_a.txt", "path/to/file_b.txt")
```

## Default Keymaps

| Key | Action |
|-----|--------|
| `]h` | Jump to next hunk |
| `[h` | Jump to previous hunk |
| `<leader>dl` | Apply hunk from left to right |
| `<leader>dr` | Apply hunk from right to left |
| `<C-h>` | Focus left window |
| `<C-l>` | Focus right window |
| `q` | Close diff view |

## Configuration

You can customize keymaps, highlights, and signs:

```lua
require("diff-edit").setup({
  keymaps = {
    next_hunk = "]h",
    prev_hunk = "[h",
    apply_left_to_right = "<leader>dl",
    apply_right_to_left = "<leader>dr",
    focus_left = "<C-h>",
    focus_right = "<C-l>",
    close = "q",
  },
  highlights = {
    add = "DiffAdd",
    change = "DiffChange",
    delete = "DiffDelete",
  },
  signs = {
    add = "+",
    change = "~",
    delete = "-",
  },
})
```

## How It Works

- Uses `vim.diff()` to compute hunks with the histogram algorithm
- Extmarks for efficient highlighting that updates automatically
- `nvim_buf_attach()` monitors buffer changes and recalculates diffs
- `scrollbind` and `cursorbind` keep both windows synchronized

## Requirements

- Neovim >= 0.8.0

## License

MIT