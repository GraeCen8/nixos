require "nvchad.autocmds"

local ih_exts = { "go", "c", "cpp", "h", "py", "odin", "zig", "lua" }

vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = vim.tbl_map(function(ext)
    return "*." .. ext
  end, ih_exts),
  callback = function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
  end,
})
