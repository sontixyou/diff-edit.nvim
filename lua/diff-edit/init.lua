-- init.lua - Public API and setup
local M = {}

local config = require("diff-edit.config")
local ui = require("diff-edit.ui")

-- Setup function to initialize the plugin
function M.setup(opts)
  config.setup(opts)
end

-- Open diff view with two files
function M.open(file_a, file_b)
  if not file_a or not file_b then
    vim.notify("Two file paths required", vim.log.levels.ERROR)
    return
  end

  ui.open(file_a, file_b, config.options)
end

-- Close the current diff session
function M.close()
  ui.close()
end

return M
