return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	cmd = "Neotree",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		require("neo-tree").setup({
			enable_session_for_tree = false,
			close_if_last_window = false,
			open_files_in_last_window = true,
			keep_altfile = true,
			components = {
				git_status = {
					symbols = {
						added = "A",
						deleted = "D",
						modified = "M",
						renamed = "R",
						staged = "S",
						conflict = "C",
						untracked = "U",
					},
				},
			},
			filesystem = {
				bind_to_cwd = false,
				enable_file_watcher = true,
				filtered_items = {
					visible = false,
					hide_dotfiles = false,
					hide_gitignored = true,
					hide_by_name = { "node_modules", ".venv", "venv", "__pycache__", ".git" },
				},
				follow_current_file = { enabled = true, leave_dirs_open = true },
				use_libuv_file_watcher = true,
			},
			window = {
				position = "left",
				width = 40,
				auto_refresh_on_change = true,
				mappings = {
					["<Tab>"] = function()
						require("explorer").editor()
					end,
					["<S-Tab>"] = function()
						require("explorer").editor()
					end,
					["<Esc>"] = function()
						require("explorer").editor()
					end,
					["<C-l>"] = function()
						require("explorer").editor()
					end,
					["<C-b>"] = function()
						require("explorer").toggle()
					end,
				},
			},
		})
	end,
}
