return {
	"mrcjkb/rustaceanvim",
	version = "^6", -- Recommended
	lazy = false, -- This plugin is already lazy
	config = function()
		local data = vim.fn.stdpath("data")
		local pkg_base = data .. "/mason/packages/codelldb/extension"
		local codelldb_path = pkg_base .. "/adapter/codelldb"
		local liblldb_path = pkg_base .. "/lldb/lib/liblldb." .. (vim.fn.has("mac") == 1 and "dylib" or "so")

		local cfg = require("rustaceanvim.config")
		vim.g.rustaceanvim = {
			server = {
				capabilities = vim.lsp.protocol.make_client_capabilities(),
				default_settings = {
					["rust-analyzer"] = {
						cargo = { buildScripts = { enable = true } },
						procMacro = { enable = true },
						check = { command = "clippy" },
					},
				},
			},
			dap = {
				adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path),
			},
			tools = {
				use_telescope = true,
				inlay_hints = { enabled = true },
			},
		}

	end,
}
