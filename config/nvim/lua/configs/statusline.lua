local M = {}

-- Statusline module: file path relative to cwd (or ~), instead of just the name.
M.file_path = function()
  local path = vim.fn.expand "%:~:."
  if path == "" then
    path = "[No Name]"
  end
  -- "%" is special in statusline strings
  return "%#St_file# " .. "%F" .. "%#St_file_sep#" .. ""
end

return M
