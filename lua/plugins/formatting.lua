return {
	"stevearc/conform.nvim",
	cmd = "ConformInfo",
	event = "BufWritePre",
	opts = {
		notify_on_error = true,
		default_format_opts = { lsp_format = "fallback" },
		format_on_save = function(bufnr)
			if
				vim.g.disable_autoformat
				or vim.b[bufnr].disable_autoformat
				or vim.bo[bufnr].buftype ~= ""
				or vim.bo[bufnr].filetype == "bigfile"
				or vim.api.nvim_buf_get_offset(bufnr, vim.api.nvim_buf_line_count(bufnr)) > 1024 * 1024
			then
				return
			end
			return { timeout_ms = 500, lsp_format = "fallback" }
		end,
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
			go = { "goimports", "gofumpt" },
			javascript = { "prettierd" },
			typescript = { "prettierd" },
			javascriptreact = { "prettierd" },
			typescriptreact = { "prettierd" },
			css = { "prettierd" },
			scss = { "prettierd" },
			html = { "prettierd" },
			json = { "prettierd" },
			jsonc = { "prettierd" },
			yaml = { "prettierd" },
			markdown = { "prettierd" },
			rust = { "rustfmt" },
			toml = { "taplo" },
			proto = { "buf" },
			sql = { "sql_formatter" },
			sh = { "shfmt" },
			bash = { "shfmt" },
			c = { "clang-format" },
			cpp = { "clang-format" },
			objc = { "clang-format" },
			objcpp = { "clang-format" },
		},
	},
}
