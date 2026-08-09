return {
  "dmtrKovalenko/fff.nvim",
  build = function()
    -- downloads a prebuilt binary or falls back to cargo build
    require("fff.download").download_or_build_binary()
  end,
  -- for nixos:
  -- build = "nix run .#release",
  opts = {
    debug = {
      enabled = true,
      show_scores = true,
    },
  },
  lazy = false, -- the plugin lazy-initialises itself
  keys = {
    {
      "<leader>sf",
      function()
        require("fff").find_files()
      end,
      desc = "FFFind files",
    },
    {
      "<leader>sg",
      function()
        require("fff").live_grep()
      end,
      desc = "LiFFFe grep",
    },
    {
      "<leader>sz",
      function()
        require("fff").live_grep { grep = { modes = { "fuzzy", "plain" } } }
      end,
      desc = "Live fuzzy grep",
    },
    {
      "<leader>sw",
      function()
        require("fff").live_grep_under_cursor()
      end,
      mode = { "n", "x" },
      desc = "Search current word / selection",
    },
  },
  config = function()
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        if vim.fn.argc() == 0 or (vim.fn.argv(0) and vim.fn.isdirectory(vim.fn.argv(0)) == 1) then
          require("fff").find_files()
        end
      end,
    })
  end,
}


