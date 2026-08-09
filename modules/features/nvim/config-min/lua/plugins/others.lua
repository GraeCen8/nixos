return {
	{ "ojroques/vim-oscyank" },
	{ "tpope/vim-fugitive" },
	{
		"brenoprata10/nvim-highlight-colors",
		config = function()
			require("nvim-highlight-colors").setup({})
		end,
	},
	{ "folke/which-key.nvim", event = "VeryLazy", opts = {} },
	{ "lewis6991/gitsigns.nvim", event = { "BufReadPre", "BufNewFile" }, opts = {} },
	{ "kylechui/nvim-surround", version = "*", opts = {} },
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {},
		keys = {
			{
				"s",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash",
			},
		},
	},
	{
		"kdheepak/lazygit.nvim",
		lazy = true,
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		-- optional for floating window border decoration
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		-- setting the keybinding for LazyGit with 'keys' is recommended in
		-- order to load the plugin when the command is run for the first time
		keys = {
			{ "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
		},
	},
	{
		"mrcjkb/rustaceanvim",
		version = "^9",
		lazy = false,
	},
}
