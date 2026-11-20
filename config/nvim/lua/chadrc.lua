-- Same structure as nvconfig.lua: https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua

---@type ChadrcConfig
local M = {}

local DARK_THEME = "oceanic-next"
local LIGHT_THEME = "one_light"

-- `bin/theme-switch` writes the wanted theme name here (outside the repo, so
-- switching never dirties git). Fall back to the dark theme if it's missing.
local function current_theme()
  local f = io.open(vim.env.HOME .. "/.local/state/dotfiles/nvim-theme", "r")
  if not f then
    return DARK_THEME
  end
  local theme = f:read "*l"
  f:close()
  return (theme and theme ~= "") and theme or DARK_THEME
end

M.base46 = {
  theme = current_theme(),
  theme_toggle = { DARK_THEME, LIGHT_THEME },
}

-- Installed by :MasonInstallAll. Listed explicitly because NvChad's
-- auto-detection misses servers enabled with vim.lsp.enable (nvim 0.12).
-- Keep in sync with `servers` in configs/lspconfig.lua and conform's formatters.
M.mason = {
  pkgs = {
    "lua-language-server",
    "html-lsp", -- html
    "css-lsp", -- cssls
    "gopls",
    "pyright",
    "stylua",
  },
}

M.ui = {
  statusline = {
    theme = "default",
    separator_style = "default",
    order = { "mode", "file_p", "git", "%=", "lsp_msg", "%=", "lsp", "cwd" },
    modules = {
      file_p = require("configs.statusline").file_path,
    },
  },
}

return M
