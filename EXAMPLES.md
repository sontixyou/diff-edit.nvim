## Examples

### Basic Usage

```vim
" Open two files in diff mode
:DiffEdit old_version.py new_version.py
```

### Navigation

Once in diff mode, you can:
- Press `]h` to jump to the next hunk
- Press `[h` to jump to the previous hunk
- Use normal Vim commands to edit both files

### Applying Changes

Position your cursor on any hunk and:
- Press `<leader>dl` to apply changes from left to right
- Press `<leader>dr` to apply changes from right to left

### Window Management

- Press `<C-h>` to focus the left window
- Press `<C-l>` to focus the right window
- Press `q` to close the diff view

## Advanced Configuration

### Custom Keymaps

```lua
require("diff-edit").setup({
  keymaps = {
    next_hunk = "<C-j>",        -- Use Ctrl-j for next hunk
    prev_hunk = "<C-k>",        -- Use Ctrl-k for previous hunk
    apply_left_to_right = "gl", -- Use gl for left-to-right
    apply_right_to_left = "gr", -- Use gr for right-to-left
    focus_left = "<leader>h",   -- Use leader+h for left window
    focus_right = "<leader>l",  -- Use leader+l for right window
    close = "<Esc>",            -- Use Escape to close
  },
})
```

### Custom Highlights

```lua
require("diff-edit").setup({
  highlights = {
    add = "GitSignsAdd",      -- Use GitSigns highlight groups
    change = "GitSignsChange",
    delete = "GitSignsDelete",
  },
  signs = {
    add = "┃",      -- Use different sign characters
    change = "┃",
    delete = "▁",
  },
})
```

## Tips

1. **Synchronized Scrolling**: Both windows are synchronized with `scrollbind` and `cursorbind`, so moving in one window moves both.

2. **Automatic Updates**: The diff is automatically recalculated whenever you edit either file.

3. **Direct Editing**: You can edit files directly in the diff view - no need to accept/reject before making manual edits.

4. **Multiple Sessions**: You can open multiple diff tabs simultaneously, but each command opens a new tab.

## Comparison with vimdiff

| Feature | diff-edit.nvim | vimdiff |
|---------|----------------|---------|
| Interface | Clean side-by-side | Multiple modes |
| Hunk navigation | `]h` / `[h` | `]c` / `[c` |
| Apply changes | `<leader>dl` / `<leader>dr` | `:diffget` / `:diffput` |
| Setup | `:DiffEdit file1 file2` | `nvim -d file1 file2` or `:diffsplit` |
| Auto-update | Yes | Yes |
| Learning curve | Low | Higher |
