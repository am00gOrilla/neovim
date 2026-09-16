return {
	"linux-cultist/venv-selector.nvim",
	dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim" },
	ft = "python",
	cmd = { "VenvSelect", "VenvSelectCached" },
	opts = {
		cache = { file = vim.fn.stdpath("cache") .. "/venv-selector/venvs.json" },
		options = {
			picker = "telescope",
			override_notify = false,
			activate_venv_in_terminal = true,
			cached_venv_automatic_activation = true,
			on_telescope_result_callback = function(filename)
				return vim.fn.fnamemodify(filename, ":~"):gsub("/bin/python$", "")
			end,
		},
	},
}
