require("nvchad.configs.lspconfig").defaults()

vim.lsp.config("gopls", {
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
      gofumpt = true,
    },
  },
})

vim.lsp.config("pyright", {
  settings = {
    pyright = {
      -- Set to true if using Ruff for import sorting
      disableOrganizeImports = false,
    },
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "openFilesOnly", -- Change to 'workspace' to check all files
        typeCheckingMode = "basic", -- Options: 'off', 'basic', 'standard', 'strict'
      },
    },
  },
})

local servers = { "html", "cssls", "gopls", "pyright" }
vim.lsp.enable(servers)
