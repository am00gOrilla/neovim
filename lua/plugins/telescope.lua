return {
	"nvim-telescope/telescope.nvim",
	tag = "v0.2.1", -- Uses Neovim's Tree-sitter API; 0.1.8 breaks with nvim-treesitter main.
	cmd = "Telescope",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
			cond = function()
				return vim.fn.executable("make") == 1
			end,
		},
		"nvim-tree/nvim-web-devicons",
		"nvim-telescope/telescope-ui-select.nvim",
	},
	config = function()
		local telescope = require("telescope")
		telescope.setup({
			defaults = {
				file_ignore_patterns = { "node_modules/", "%.venv/", "venv/", "__pycache__/", "%.git/" },
			},
			pickers = { find_files = { hidden = true } },
			extensions = { ["ui-select"] = { require("telescope.themes").get_dropdown({}) } },
		})
		pcall(telescope.load_extension, "fzf")
		telescope.load_extension("ui-select")
		pcall(telescope.load_extension, "persisted")
	end,
}
