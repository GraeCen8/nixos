require("nvchad.configs.lspconfig").defaults()

local servers = {
  "lua_ls",
  "rust_analyzer",
  "clangd",
  "gopls",
  "nixd",
  "taplo",
  "ts_ls",
  "pyright",
  "tailwindcss",
  "eslint-lsp",
}
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
