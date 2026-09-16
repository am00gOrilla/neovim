return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	dependencies = { "mason-org/mason.nvim" },
	build = ":TSUpdate",
	config = function()
		local ts = require("nvim-treesitter")
		ts.setup({})
		local parsers = {
			"lua",
			"vim",
			"vimdoc",
			"query",
			"regex",
			"python",
			"rust",
			"toml",
			"json",
			"yaml",
			"dockerfile",
			"typescript",
			"javascript",
			"tsx",
			"html",
			"css",
			"sql",
			"bash",
			"go",
			"gomod",
			"gosum",
			"gowork",
			"c",
			"cpp",
			"cmake",
			"objc",
			"markdown",
			"markdown_inline",
		}
		vim.api.nvim_create_user_command("DevParsersInstall", function()
			ts.install(parsers)
		end, { desc = "Install development language parsers" })

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("DevelopmentTreesitter", { clear = true }),
			callback = function(args)
				local ft = vim.bo[args.buf].filetype
				local lang = vim.treesitter.language.get_lang(ft)
				if not lang or not vim.tbl_contains(parsers, lang) then
					return
				end
				if vim.api.nvim_buf_get_offset(args.buf, vim.api.nvim_buf_line_count(args.buf)) > 1024 * 1024 then
					return
				end
				if not pcall(vim.treesitter.start, args.buf, lang) then
					return
				end
				-- Parser names differ from filetypes: tsx -> typescriptreact, bash -> sh.
				if vim.treesitter.query.get(lang, "indents") then
					vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})
	end,
}
