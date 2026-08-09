return {
  "akinsho/toggleterm.nvim",
  version = "*",
  keys = {
    { "<leader>h", "<cmd>ToggleTerm direction=horizontal<CR>", desc = "Toggle bottom terminal" },
    { "<leader>v", "<cmd>ToggleTerm direction=float<CR>", desc = "Toggle floating terminal" },
    { "<leader>e", "<cmd>ToggleTerm direction=vertical<CR>", desc = "Toggle right terminal" },
    { "<C-\\>", "<cmd>ToggleTerm<CR>", desc = "Toggle terminal", mode = { "n", "t" } },
  },
  config = function()
    require("toggleterm").setup({
      size = 15,
      open_mapping = [[<C-\>]],
      hide_numbers = true,
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      terminal_mappings = true,
      direction = "float",
      close_on_exit = true,
      float_opts = {
        border = "curved",
        width = 120,
        height = 45,
      },
    })

    -- leave terminal insert mode
    vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>")
  end,
}

