return {
	{
		"mfussenegger/nvim-dap",
		lazy = true,
		keys = {
			{ "<F5>", function() require("dap").continue() end, desc = "Start/Continue" },
			{ "<S-F5>", function() require("dap").terminate() end, desc = "Stop" },
			{ "<F10>", function() require("dap").step_over() end, desc = "Step over" },
			{ "<F11>", function() require("dap").step_into() end, desc = "Step into" },
			{ "<S-F11>", function() require("dap").step_out() end, desc = "Step out" },
			{ "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
			{ "<leader>dB", function() require("dap").set_breakpoint() end, desc = "Set breakpoint" },
			{ "<leader>dC", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end, desc = "Conditional breakpoint" },
			{ "<leader>dl", function() require("dap").run_last() end, desc = "Run last config" },
			{ "<leader>do", function() require("dap").repl.open() end, desc = "DAP REPL" },
		},
		config = function()
			local dap = require("dap")

			-- Go (delve)
			dap.adapters.go = {
				type = "server",
				port = "${port}",
				executable = { command = "dlv", args = { "dap", "-l", "127.0.0.1:${port}" } },
			}

			-- C / C++ / Rust (lldb-dap)
			dap.adapters.lldb = {
				type = "server",
				port = "${port}",
				executable = { command = "lldb-dap", args = { "--port", "${port}" } },
			}

			-- Python (debugpy)
			dap.adapters.python = {
				type = "executable",
				command = "python3",
				args = { "-m", "debugpy.adapter" },
			}

			dap.configurations.go = {
				{
					type = "go",
					name = "Debug (Delve)",
					request = "launch",
					program = "${workspaceFolder}",
				},
			}

			dap.configurations.python = {
				{
					type = "python",
					name = "Debug (debugpy)",
					request = "launch",
					program = "${file}",
				},
			}

			local launch = {
				name = "Launch (lldb-dap)",
				type = "lldb",
				request = "launch",
				program = function()
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
				end,
				cwd = "${workspaceFolder}",
				stopOnEntry = false,
			}
			dap.configurations.c = { launch }
			dap.configurations.cpp = { launch }
			dap.configurations.rust = { launch }
		end,
	},
	{
		"rcarriga/nvim-dap-ui",
		dependencies = {
			"mfussenegger/nvim-dap",
			"nvim-neotest/nvim-nio",
		},
		event = "VeryLazy",
		keys = {
			{ "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
		},
		config = function()
			local dapui = require("dapui")
			dapui.setup({})
			local dap = require("dap")
			dap.listeners.after.event_initialized["dapui_config"] = dapui.open
			dap.listeners.before.event_terminated["dapui_config"] = dapui.close
			dap.listeners.before.event_exited["dapui_config"] = dapui.close
		end,
	},
	{
		"theHamsta/nvim-dap-virtual-text",
		dependencies = { "mfussenegger/nvim-dap", "nvim-treesitter/nvim-treesitter" },
		event = "VeryLazy",
		opts = {},
	},
}
