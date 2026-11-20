-- Keeps NvChad's compiled highlight cache (base46) in step with chadrc.
--
-- NvChad paints from the precompiled cache, not from chadrc, so changing the
-- theme in chadrc (or via bin/theme-switch) only shows once the cache is
-- rebuilt. We record which theme the cache was built for and rebuild when
-- it no longer matches.
local M = {}

local stamp = vim.g.base46_cache .. ".theme"

local function read_stamp()
  local f = io.open(stamp, "r")
  if not f then
    return nil
  end
  local theme = f:read "*l"
  f:close()
  return theme
end

local function write_stamp(theme)
  local f = io.open(stamp, "w")
  if f then
    f:write(theme, "\n")
    f:close()
  end
end

-- Called at startup (init.lua): rebuild the cache only if the theme changed.
M.sync = function()
  local theme = require("chadrc").base46.theme
  if read_stamp() ~= theme then
    -- compile only: init.lua and each plugin load their cache files right after.
    -- (load_all_highlights() would also poke plugins like ibl too early.)
    require("base46").compile()
    write_stamp(theme)
  end
end

-- Called by bin/theme-switch in running instances: re-read chadrc and repaint.
M.reload = function()
  require("nvchad.utils").reload() -- reloads chadrc, recompiles and applies the cache
  write_stamp(require("chadrc").base46.theme)
end

return M
