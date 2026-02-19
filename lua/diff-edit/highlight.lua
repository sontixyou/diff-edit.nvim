-- highlight.lua - Extmark-based highlighting for diff hunks
local M = {}

local ns_id = vim.api.nvim_create_namespace("diff_edit_highlights")

-- Clear all highlights in a buffer
function M.clear_highlights(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)
end

-- Apply highlights to a buffer based on hunks
function M.apply_highlights(buf, hunks, side, config)
  M.clear_highlights(buf)

  if not vim.api.nvim_buf_is_valid(buf) or not hunks then
    return
  end

  for _, hunk in ipairs(hunks) do
    local start_line, count
    if side == "a" then
      start_line = hunk.start_a
      count = hunk.count_a
    else
      start_line = hunk.start_b
      count = hunk.count_b
    end

    -- Determine hunk type
    local hl_group, sign_text
    if hunk.count_a == 0 then
      -- Addition (only in B)
      hl_group = config.highlights.add
      sign_text = config.signs.add
    elseif hunk.count_b == 0 then
      -- Deletion (only in A)
      hl_group = config.highlights.delete
      sign_text = config.signs.delete
    else
      -- Change (in both)
      hl_group = config.highlights.change
      sign_text = config.signs.change
    end

    -- Apply highlight and sign for this side
    if count > 0 then
      -- Highlight lines
      for i = 0, count - 1 do
        local line = start_line - 1 + i
        if line >= 0 and line < vim.api.nvim_buf_line_count(buf) then
          vim.api.nvim_buf_set_extmark(buf, ns_id, line, 0, {
            end_row = line + 1,
            hl_group = hl_group,
            hl_eol = true,
            sign_text = sign_text,
            sign_hl_group = hl_group,
          })
        end
      end
    elseif count == 0 and side == "a" and hunk.count_b > 0 then
      -- Handle deletion display on side A (show marker at the position)
      local line = start_line - 1
      if line >= 0 and line < vim.api.nvim_buf_line_count(buf) then
        vim.api.nvim_buf_set_extmark(buf, ns_id, line, 0, {
          virt_lines = { { { "--- deleted ---", hl_group } } },
          virt_lines_above = false,
        })
      end
    elseif count == 0 and side == "b" and hunk.count_a > 0 then
      -- Handle addition display on side B (show marker at the position)
      local line = start_line - 1
      if line >= 0 and line < vim.api.nvim_buf_line_count(buf) then
        vim.api.nvim_buf_set_extmark(buf, ns_id, line, 0, {
          virt_lines = { { { "--- added ---", hl_group } } },
          virt_lines_above = false,
        })
      end
    end
  end
end

return M
