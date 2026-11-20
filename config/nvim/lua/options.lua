require "nvchad.options"

-- add yours here!

local o = vim.o
o.cursorlineopt = "both" -- to enable cursorline!
o.relativenumber = true

-- Format-on-save toggles (format_on_save itself lives in configs/conform.lua)
vim.api.nvim_create_user_command("FormatDisable", function(args)
  if args.bang then
    -- FormatDisable! will disable formatting just for this buffer
    vim.b.disable_autoformat = true
  else
    vim.g.disable_autoformat = true
  end
end, {
  desc = "Disable autoformat-on-save",
  bang = true,
})

vim.api.nvim_create_user_command("FormatEnable", function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, {
  desc = "Re-enable autoformat-on-save",
})

-- markdown-preview.nvim: reachable from other machines on the network.
-- Set vim.g.mkdp_open_ip to this machine's LAN IP if the echoed URL is wrong.
vim.g.mkdp_open_to_the_world = 1
vim.g.mkdp_echo_preview_url = 1
