-- actions.lua - Accept/reject operations for hunks
local M = {}

local hunk_module = require("diff-edit.hunk")

-- Apply a hunk from source buffer to destination buffer
function M.apply_hunk(hunk, src_buf, dst_buf)
  if not hunk or not vim.api.nvim_buf_is_valid(src_buf) or not vim.api.nvim_buf_is_valid(dst_buf) then
    return false
  end

  local src_start = hunk.start_a - 1
  local src_count = hunk.count_a
  local dst_start = hunk.start_b - 1
  local dst_count = hunk.count_b

  -- Get source lines
  local src_lines = {}
  if src_count > 0 then
    src_lines = vim.api.nvim_buf_get_lines(src_buf, src_start, src_start + src_count, false)
  end

  -- Replace destination lines
  vim.api.nvim_buf_set_lines(dst_buf, dst_start, dst_start + dst_count, false, src_lines)

  return true
end

-- Apply current hunk from left to right
function M.apply_left_to_right(state)
  if not state or not state.buf_a or not state.buf_b or not state.hunks then
    vim.notify("Diff session not active", vim.log.levels.ERROR)
    return
  end

  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(win)
  local cursor = vim.api.nvim_win_get_cursor(win)
  local line = cursor[1]

  -- Determine which side we're on
  local side
  if buf == state.buf_a then
    side = "a"
  elseif buf == state.buf_b then
    side = "b"
  else
    vim.notify("Not in a diff buffer", vim.log.levels.ERROR)
    return
  end

  -- Find hunk at cursor
  local hunk, idx = hunk_module.find_hunk_at_line(state.hunks, line, side)
  if not hunk then
    vim.notify("No hunk at cursor", vim.log.levels.WARN)
    return
  end

  -- Apply from A to B
  if M.apply_hunk(hunk, state.buf_a, state.buf_b) then
    vim.notify("Applied hunk from left to right", vim.log.levels.INFO)
  end
end

-- Apply current hunk from right to left
function M.apply_right_to_left(state)
  if not state or not state.buf_a or not state.buf_b or not state.hunks then
    vim.notify("Diff session not active", vim.log.levels.ERROR)
    return
  end

  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(win)
  local cursor = vim.api.nvim_win_get_cursor(win)
  local line = cursor[1]

  -- Determine which side we're on
  local side
  if buf == state.buf_a then
    side = "a"
  elseif buf == state.buf_b then
    side = "b"
  else
    vim.notify("Not in a diff buffer", vim.log.levels.ERROR)
    return
  end

  -- Find hunk at cursor
  local hunk, idx = hunk_module.find_hunk_at_line(state.hunks, line, side)
  if not hunk then
    vim.notify("No hunk at cursor", vim.log.levels.WARN)
    return
  end

  -- Apply from B to A (need to swap the hunk perspective)
  local reversed_hunk = {
    start_a = hunk.start_b,
    count_a = hunk.count_b,
    start_b = hunk.start_a,
    count_b = hunk.count_a,
  }

  if M.apply_hunk(reversed_hunk, state.buf_b, state.buf_a) then
    vim.notify("Applied hunk from right to left", vim.log.levels.INFO)
  end
end

return M
