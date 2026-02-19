-- plugin/diff-edit.lua - User command registration
if vim.fn.has("nvim-0.8.0") == 0 then
  vim.api.nvim_err_writeln("diff-edit.nvim requires Neovim >= 0.8.0")
  return
end

-- Prevent loading the plugin twice
if vim.g.loaded_diff_edit then
  return
end
vim.g.loaded_diff_edit = 1

-- Register :DiffEdit command
vim.api.nvim_create_user_command("DiffEdit", function(opts)
  local args = opts.fargs
  
  if #args ~= 2 then
    vim.notify("Usage: :DiffEdit <file_a> <file_b>", vim.log.levels.ERROR)
    return
  end

  require("diff-edit").open(args[1], args[2])
end, {
  nargs = "*",
  complete = "file",
  desc = "Open two files in diff-edit mode",
})
