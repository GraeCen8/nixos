local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    css = { "prettier" },
    html = { "prettier" },
    rust = { "rustfmt" },
    go = { "gofmt" },
    nix = { "nixfmt" },
  },

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 2000,
    lsp_fallback = true,
  },
}

return options
