-- config.lua - Default configuration management
local M = {}

M.defaults = {
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
}

M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

return M
