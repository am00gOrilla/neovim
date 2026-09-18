return {
	{
		"projekt0n/github-nvim-theme",
		name = "github-theme",
		lazy = false,
		priority = 1000,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
	},
	{
		"folke/tokyonight.nvim",
		name = "tokyonight",
	},
	{
		"rebelot/kanagawa.nvim",
		name = "kanagawa",
	},
	{
		"savq/melange",
		name = "melange",
	},
	{
		"sainnhe/gruvbox-material",
		name = "gruvbox-material",
	},
	{
		"EdenEast/nightfox.nvim",
		name = "nightfox",
	},
	{
		"olimorris/onedarkpro.nvim",
		name = "onedark",
	},
	{
		"zaldih/themery.nvim",
		lazy = false,
		config = function()
			require("themery").setup({
				themes = {
					{
						name = "VS Code Dark High Contrast",
						colorscheme = "vscode_hc",
					},
					"github_dark_high_contrast",
					-- Catppuccin
					"catppuccin-frappe",
					"catppuccin-macchiato",
					"catppuccin-mocha",
					-- Tokyonight
					"tokyonight-night",
					"tokyonight-storm",
					"tokyonight-moon",
					-- Kanagawa
					"kanagawa-wave",
					"kanagawa-dragon",
					-- Melange
					"melange",
					-- Gruvbox Material
					"gruvbox-material",
					-- Nightfox
					"nightfox",
					"carbonfox",
					-- One Dark
					"onedark",
					"onedark_vivid",
					"onedark_dark",
					"vaporwave",
					-- Just a separator.
					{
						name = "───────── Light Themes ─────────",
						colorscheme = vim.g.colors_name,
						commands = { "lua --[[]]" },
					},
					-- light
					"onelight",
					"tokyonight-day",
					"catppuccin-latte",
					"dayfox",
					"kanagawa-lotus",
				},
				livePreview = true,
			})
		end,
	},
}
