return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- needed for format on save
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- Nvim half of tmux's christoomey/vim-tmux-navigator: Ctrl-hjkl moves
  -- between nvim splits and tmux panes seamlessly. Keys are set in
  -- mappings.lua (after NvChad's own <C-hjkl>, which would override them here).
  {
    "christoomey/vim-tmux-navigator",
    cmd = { "TmuxNavigateLeft", "TmuxNavigateDown", "TmuxNavigateUp", "TmuxNavigateRight" },
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
}
