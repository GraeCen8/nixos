local api = vim.api

local function check_triggeredChars(triggerChars)
	local cur_line = api.nvim_get_current_line()
	local pos = api.nvim_win_get_cursor(0)[2]
	local prev_char = cur_line:sub(pos - 1, pos - 1)
	local cur_char = cur_line:sub(pos, pos)

	for _, char in ipairs(triggerChars) do
		if cur_char == char or prev_char == char then
			return true
		end
	end
end

local function setupSignature(client, bufnr)
	-- Guard against invalid or already deleted buffers (e.g. async vim.schedule callbacks)
	if not bufnr or not api.nvim_buf_is_valid(bufnr) then
		return
	end

	local group = api.nvim_create_augroup("LspSignature", { clear = false })
	api.nvim_clear_autocmds({ group = group, buffer = bufnr })

	local triggerChars = client.server_capabilities.signatureHelpProvider.triggerCharacters

	api.nvim_create_autocmd("TextChangedI", {
		group = group,
		buffer = bufnr,
		callback = function()
			if check_triggeredChars(triggerChars) then
				vim.lsp.buf.signature_help({ focus = false, silent = true, max_height = 7, border = "single" })
			end
		end,
	})
end

return {
	{
		"neovim/nvim-lspconfig",

		dependencies = {
			{
				"folke/lazydev.nvim",
				ft = "lua",
				opts = {
					library = {
						{
							path = "${3rd}/luv/library",
							words = { "vim%.uv" },
						},
					},
				},
			},
		},

		config = function()
			local servers = {
				"lua_ls",
				"rust_analyzer",
				"clangd",
				"gopls",
				"nixd",
				"taplo",
				"ts_ls",
				"pyright",
			}

			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						diagnostics = { globals = { "vim" } },
						workspace = {
							library = vim.api.nvim_get_runtime_file("", true),
							checkThirdParty = false,
						},
						telemetry = { enable = false },
					},
				},
			})

			-- Configure and enable LSPs
			for _, server in ipairs(servers) do
				vim.lsp.config(server, {})
				vim.lsp.enable(server)
			end

			-- Diagnostics
			vim.diagnostic.config({
				virtual_text = {
					spacing = 2,
				},
				signs = true,
				underline = true,
				update_in_insert = false,
				severity_sort = true,
				float = {
					border = "rounded",
				},
			})

			-- LSP attach
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if not client then
						return
					end
					local opts = { buffer = args.buf }

					setupSignature(client, args.buf)

					-- Navigation
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
					vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)

					-- Information
					vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
					vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, opts)

					-- Actions
					vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
					vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)

					-- Workspace
					vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
					vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
					vim.keymap.set("n", "<leader>wl", vim.lsp.buf.list_workspace_folders, opts)

					-- Document highlighting
					if client:supports_method("textDocument/documentHighlight") then
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = args.buf,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = args.buf,
							callback = vim.lsp.buf.clear_references,
						})
					end
				end,
			})

			-- Toggle inlay hints
			vim.keymap.set("n", "<leader>ih", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
			end)

			-- Code lens
			vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run)

			-- Diagnostics
			vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
			vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
			vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float)
		end,
	},

	{
		"stevearc/conform.nvim",
		event = { "BufWritePre", "BufNewFile" },
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				nix = { "nixfmt" },
				go = { "gofmt" },
				rust = { "rustfmt" },
				c = { "clang_format" },
				cpp = { "clang_format" },
				python = { "ruff_format", "black", stop_after_first = true },
				toml = { "taplo" },
				zig = { "zigfmt" },
				odin = { "odinfmt" },
				javascript = { "prettierd", "prettier", stop_after_first = true },
				typescript = { "prettierd", "prettier", stop_after_first = true },
				tsx = { "prettierd", "prettier", stop_after_first = true },
				html = { "prettierd", "prettier", stop_after_first = true },
				css = { "prettierd", "prettier", stop_after_first = true },
				json = { "prettierd", "prettier", stop_after_first = true },
				yaml = { "prettierd", "prettier", stop_after_first = true },
				markdown = { "prettierd", "prettier", stop_after_first = true },
			},
			format_on_save = { timeout_ms = 2000, lsp_format = "fallback" },
		},
	},

	{
		"saghen/blink.cmp",
		version = "1.*",

		dependencies = {
			"rafamadriz/friendly-snippets",
			{ "L3MON4D3/LuaSnip", version = "2.*" },
		},

		opts = {
			snippets = { preset = "luasnip" },
			keymap = {
				["<C-n>"] = { "insert_next", "fallback" },
			},
			completion = {
				list = {
					selection = {
						preselect = false,
						auto_insert = false,
					},
				},
				accept = {
					auto_brackets = {
						enabled = true,
					},
				},
			},
		},
	},

	{
		"j-hui/fidget.nvim",
		opts = {},
	},
	{
		"folke/trouble.nvim",
		opts = {}, -- for default options, refer to the configuration section for custom setup.
		cmd = "Trouble",
		keys = {
			{
				"<leader>xx",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Diagnostics (Trouble)",
			},
			{
				"<leader>xX",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				desc = "Buffer Diagnostics (Trouble)",
			},
			{
				"<leader>cs",
				"<cmd>Trouble symbols toggle focus=false<cr>",
				desc = "Symbols (Trouble)",
			},
			{
				"<leader>cl",
				"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
				desc = "LSP Definitions / references / ... (Trouble)",
			},
			{
				"<leader>xL",
				"<cmd>Trouble loclist toggle<cr>",
				desc = "Location List (Trouble)",
			},
			{
				"<leader>xQ",
				"<cmd>Trouble qflist toggle<cr>",
				desc = "Quickfix List (Trouble)",
			},
		},
	},
}
