-- hunk.lua - Hunk analysis and navigation using vim.diff()
local M = {}

-- Compute hunks between two buffers using vim.diff()
-- Returns array of hunks: { start_a, count_a, start_b, count_b }
function M.compute_hunks(buf_a, buf_b)
  local lines_a = vim.api.nvim_buf_get_lines(buf_a, 0, -1, false)
  local lines_b = vim.api.nvim_buf_get_lines(buf_b, 0, -1, false)

  local diff_result = vim.diff(table.concat(lines_a, "\n"), table.concat(lines_b, "\n"), {
    result_type = "indices",
    algorithm = "histogram",
  })

  if not diff_result then
    return {}
  end

  local hunks = {}
  for _, hunk in ipairs(diff_result) do
    table.insert(hunks, {
      start_a = hunk[1],
      count_a = hunk[2],
      start_b = hunk[3],
      count_b = hunk[4],
    })
  end

  return hunks
end

-- Find the hunk at or after the given line in buffer
function M.find_hunk_at_line(hunks, line, side)
  if not hunks or #hunks == 0 then
    return nil, nil
  end

  for idx, hunk in ipairs(hunks) do
    local start_line, count
    if side == "a" then
      start_line = hunk.start_a
      count = hunk.count_a
    else
      start_line = hunk.start_b
      count = hunk.count_b
    end

    -- Check if line is within this hunk
    if line >= start_line and line < start_line + count then
      return hunk, idx
    end
  end

  return nil, nil
end

-- Get the next hunk after the given line
function M.get_next_hunk(hunks, line, side)
  if not hunks or #hunks == 0 then
    return nil, nil
  end

  for idx, hunk in ipairs(hunks) do
    local start_line
    if side == "a" then
      start_line = hunk.start_a
    else
      start_line = hunk.start_b
    end

    if start_line > line then
      return hunk, idx
    end
  end

  return nil, nil
end

-- Get the previous hunk before the given line
function M.get_prev_hunk(hunks, line, side)
  if not hunks or #hunks == 0 then
    return nil, nil
  end

  local prev_hunk, prev_idx = nil, nil
  for idx, hunk in ipairs(hunks) do
    local start_line
    if side == "a" then
      start_line = hunk.start_a
    else
      start_line = hunk.start_b
    end

    if start_line >= line then
      break
    end

    prev_hunk = hunk
    prev_idx = idx
  end

  return prev_hunk, prev_idx
end

return M
