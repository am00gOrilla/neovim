return {
	"mfussenegger/nvim-dap",
	lazy = true,
	cmd = { "DapContinue", "DapToggleBreakpoint", "DapTerminate", "DapShowLog" },
	dependencies = {
		"mason-org/mason.nvim",
		"nvim-neotest/nvim-nio",
		"rcarriga/nvim-dap-ui",
		"mfussenegger/nvim-dap-python",
		"theHamsta/nvim-dap-virtual-text",
	},
	config = function()
		local dap, dapui = require("dap"), require("dapui")
		local dev = require("dev")
		local function go_package()
			local directory = vim.fn.expand("%:p:h")
			return vim.uv.fs_realpath(directory) or directory
		end
		dapui.setup({})
		require("nvim-dap-virtual-text").setup({})

		-- The adapter has its own debugpy environment; the program uses the project Python.
		local debugpy = vim.fn.stdpath("data")
			.. "/mason/packages/debugpy/venv/"
			.. (vim.fn.has("win32") == 1 and "Scripts/python.exe" or "bin/python")
		require("dap-python").setup(debugpy)
		require("dap-python").resolve_python = dev.python
		for _, config in ipairs(dap.configurations.python) do
			config.cwd = dev.root
		end

		dap.adapters.delve = {
			type = "server",
			port = "${port}",
			options = { initialize_timeout_sec = 30 }, -- The first debug build can be slow.
			executable = { command = "dlv", args = { "dap", "-l", "127.0.0.1:${port}" } },
		}
		dap.configurations.go = {
			{
				type = "delve",
				name = "Debug package",
				request = "launch",
				mode = "debug",
				program = go_package,
				cwd = dev.root,
				dlvCwd = dev.root, -- Delve's build directory is separate from the program's cwd.
			},
			{
				type = "delve",
				name = "Debug package tests",
				request = "launch",
				mode = "test",
				program = go_package,
				cwd = dev.root,
				dlvCwd = dev.root,
			},
			{
				type = "delve",
				name = "Attach to Go process",
				request = "attach",
				mode = "local",
				processId = require("dap.utils").pick_process,
				cwd = dev.root,
			},
		}

		-- Select Mason's bundled LLDB rather than searching for a system installation.
		local codelldb_args = { "--port", "${port}" }
		if vim.fn.has("win32") == 0 then
			local library = vim.fn.stdpath("data")
				.. "/mason/packages/codelldb/extension/lldb/lib/liblldb."
				.. (vim.fn.has("mac") == 1 and "dylib" or "so")
			vim.list_extend(codelldb_args, { "--liblldb", library })
		end
		dap.adapters.codelldb = {
			type = "server",
			port = "${port}",
			executable = { command = "codelldb", args = codelldb_args },
		}
		dap.configurations.c = {
			{
				type = "codelldb",
				name = "Debug executable",
				request = "launch",
				program = function()
					local path = vim.fn.input("Path to executable: ", dev.root() .. "/build/", "file")
					return path ~= "" and path or dap.ABORT
				end,
				cwd = dev.root,
				terminal = "integrated",
			},
		}
		dap.configurations.cpp = dap.configurations.c
		dap.configurations.objc = dap.configurations.c
		dap.configurations.objcpp = dap.configurations.c

		dap.adapters["pwa-node"] = {
			type = "server",
			host = "127.0.0.1",
			port = "${port}",
			executable = { command = "js-debug-adapter", args = { "${port}", "127.0.0.1" } },
		}
		dap.adapters.node = dap.adapters["pwa-node"]
		for _, ft in ipairs({ "javascript", "javascriptreact", "typescript", "typescriptreact" }) do
			dap.configurations[ft] = {
				{
					type = "pwa-node",
					name = "Launch file (Node.js)",
					request = "launch",
					program = "${file}",
					cwd = dev.root,
					sourceMaps = true,
					console = "integratedTerminal",
					skipFiles = { "<node_internals>/**" },
				},
				{
					type = "pwa-node",
					name = "Attach to Node.js (--inspect)",
					request = "attach",
					processId = require("dap.utils").pick_process,
					cwd = dev.root,
					sourceMaps = true,
					skipFiles = { "<node_internals>/**" },
				},
			}
		end
		require("dap.ext.vscode").type_to_filetypes["pwa-node"] = {
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
		}
		require("dap.ext.vscode").type_to_filetypes.node = require("dap.ext.vscode").type_to_filetypes["pwa-node"]

		vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticError" })
		vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DiagnosticError" })
		vim.fn.sign_define("DapStopped", { text = "", texthl = "DiagnosticWarn", linehl = "Visual" })
		dap.listeners.after.event_initialized.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated.dapui_config = function()
			dapui.close()
		end
		dap.listeners.before.event_exited.dapui_config = function()
			dapui.close()
		end
	end,
}
