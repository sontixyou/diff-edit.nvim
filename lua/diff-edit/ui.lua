-- ui.lua - Window/layout/state management
local M = {}

local hunk_module = require("diff-edit.hunk")
local highlight = require("diff-edit.highlight")
local actions = require("diff-edit.actions")

-- Global state for the diff session
local state = {
  win_a = nil,
  win_b = nil,
  buf_a = nil,
  buf_b = nil,
  hunks = {},
  file_a = nil,
  file_b = nil,
  tab = nil,
  attach_ids = {},
}

-- Update hunks and highlights
local function update_diff()
  if not state.buf_a or not state.buf_b then
    return
  end

  -- Recompute hunks
  state.hunks = hunk_module.compute_hunks(state.buf_a, state.buf_b)

  -- Update highlights
  local config = require("diff-edit.config").options
  highlight.apply_highlights(state.buf_a, state.hunks, "a", config)
  highlight.apply_highlights(state.buf_b, state.hunks, "b", config)
end

-- Setup keymaps for a buffer
local function setup_keymaps(buf, config)
  local opts = { buffer = buf, noremap = true, silent = true }

  -- Navigation
  vim.keymap.set("n", config.keymaps.next_hunk, function()
    M.jump_to_next_hunk()
  end, opts)

  vim.keymap.set("n", config.keymaps.prev_hunk, function()
    M.jump_to_prev_hunk()
  end, opts)

  -- Actions
  vim.keymap.set("n", config.keymaps.apply_left_to_right, function()
    actions.apply_left_to_right(state)
    update_diff()
  end, opts)

  vim.keymap.set("n", config.keymaps.apply_right_to_left, function()
    actions.apply_right_to_left(state)
    update_diff()
  end, opts)

  -- Window navigation
  vim.keymap.set("n", config.keymaps.focus_left, function()
    if state.win_a and vim.api.nvim_win_is_valid(state.win_a) then
      vim.api.nvim_set_current_win(state.win_a)
    end
  end, opts)

  vim.keymap.set("n", config.keymaps.focus_right, function()
    if state.win_b and vim.api.nvim_win_is_valid(state.win_b) then
      vim.api.nvim_set_current_win(state.win_b)
    end
  end, opts)

  -- Close
  vim.keymap.set("n", config.keymaps.close, function()
    M.close()
  end, opts)
end

-- Jump to next hunk
function M.jump_to_next_hunk()
  if not state.hunks or #state.hunks == 0 then
    vim.notify("No hunks found", vim.log.levels.WARN)
    return
  end

  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(win)
  local cursor = vim.api.nvim_win_get_cursor(win)
  local line = cursor[1]

  local side
  if buf == state.buf_a then
    side = "a"
  elseif buf == state.buf_b then
    side = "b"
  else
    return
  end

  local hunk, idx = hunk_module.get_next_hunk(state.hunks, line, side)
  if hunk then
    local target_line = side == "a" and hunk.start_a or hunk.start_b
    vim.api.nvim_win_set_cursor(win, { target_line, 0 })
  else
    vim.notify("No more hunks", vim.log.levels.INFO)
  end
end

-- Jump to previous hunk
function M.jump_to_prev_hunk()
  if not state.hunks or #state.hunks == 0 then
    vim.notify("No hunks found", vim.log.levels.WARN)
    return
  end

  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(win)
  local cursor = vim.api.nvim_win_get_cursor(win)
  local line = cursor[1]

  local side
  if buf == state.buf_a then
    side = "a"
  elseif buf == state.buf_b then
    side = "b"
  else
    return
  end

  local hunk, idx = hunk_module.get_prev_hunk(state.hunks, line, side)
  if hunk then
    local target_line = side == "a" and hunk.start_a or hunk.start_b
    vim.api.nvim_win_set_cursor(win, { target_line, 0 })
  else
    vim.notify("No previous hunks", vim.log.levels.INFO)
  end
end

-- Close the diff session
function M.close()
  -- Detach buffer listeners
  for buf, attach_id in pairs(state.attach_ids) do
    if vim.api.nvim_buf_is_valid(buf) then
      pcall(vim.api.nvim_buf_detach, buf, attach_id)
    end
  end

  -- Clear highlights
  if state.buf_a and vim.api.nvim_buf_is_valid(state.buf_a) then
    highlight.clear_highlights(state.buf_a)
  end
  if state.buf_b and vim.api.nvim_buf_is_valid(state.buf_b) then
    highlight.clear_highlights(state.buf_b)
  end

  -- Close tab if it's still valid
  if state.tab and vim.api.nvim_tabpage_is_valid(state.tab) then
    local current_tab = vim.api.nvim_get_current_tabpage()
    if current_tab == state.tab then
      vim.cmd("tabclose")
    end
  end

  -- Reset state
  state.win_a = nil
  state.win_b = nil
  state.buf_a = nil
  state.buf_b = nil
  state.hunks = {}
  state.file_a = nil
  state.file_b = nil
  state.tab = nil
  state.attach_ids = {}
end

-- Open diff view with two files
function M.open(file_a, file_b, config)
  -- Resolve file paths
  file_a = vim.fn.fnamemodify(file_a, ":p")
  file_b = vim.fn.fnamemodify(file_b, ":p")

  -- Check if files exist
  if vim.fn.filereadable(file_a) == 0 then
    vim.notify("File not found: " .. file_a, vim.log.levels.ERROR)
    return
  end
  if vim.fn.filereadable(file_b) == 0 then
    vim.notify("File not found: " .. file_b, vim.log.levels.ERROR)
    return
  end

  -- Close any existing diff session
  if state.buf_a or state.buf_b then
    M.close()
  end

  -- Create new tab
  vim.cmd("tabnew")
  state.tab = vim.api.nvim_get_current_tabpage()

  -- Load left file
  vim.cmd("edit " .. vim.fn.fnameescape(file_a))
  state.buf_a = vim.api.nvim_get_current_buf()
  state.win_a = vim.api.nvim_get_current_win()
  state.file_a = file_a

  -- Set window options for left
  vim.wo[state.win_a].scrollbind = true
  vim.wo[state.win_a].cursorbind = true
  vim.wo[state.win_a].number = true
  vim.wo[state.win_a].relativenumber = false

  -- Set winbar for left
  vim.wo[state.win_a].winbar = "%f"

  -- Split and load right file
  vim.cmd("vsplit " .. vim.fn.fnameescape(file_b))
  state.buf_b = vim.api.nvim_get_current_buf()
  state.win_b = vim.api.nvim_get_current_win()
  state.file_b = file_b

  -- Set window options for right
  vim.wo[state.win_b].scrollbind = true
  vim.wo[state.win_b].cursorbind = true
  vim.wo[state.win_b].number = true
  vim.wo[state.win_b].relativenumber = false

  -- Set winbar for right
  vim.wo[state.win_b].winbar = "%f"

  -- Setup keymaps for both buffers
  setup_keymaps(state.buf_a, config)
  setup_keymaps(state.buf_b, config)

  -- Attach buffer change listeners
  state.attach_ids[state.buf_a] = vim.api.nvim_buf_attach(state.buf_a, false, {
    on_lines = function()
      vim.schedule(update_diff)
    end,
  })

  state.attach_ids[state.buf_b] = vim.api.nvim_buf_attach(state.buf_b, false, {
    on_lines = function()
      vim.schedule(update_diff)
    end,
  })

  -- Initial diff computation
  update_diff()

  -- Focus on left window
  vim.api.nvim_set_current_win(state.win_a)
end

return M
