vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
-- vim.cmd("set number") alternative approach.
vim.opt.number = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.spelllang = "en_us"
vim.opt.spell = false
vim.opt.autoread = true
vim.g.mapleader = " "

vim.opt.updatetime = 250
vim.opt.timeoutlen = 400
vim.opt.signcolumn = "yes"
vim.opt.undofile = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.scrolloff = 4

local group = vim.api.nvim_create_augroup("DevelopmentOptions", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"json",
		"jsonc",
		"yaml",
		"html",
		"css",
		"scss",
	},
	callback = function()
		vim.opt_local.shiftwidth = 2
		vim.opt_local.softtabstop = 2
		vim.opt_local.tabstop = 2
	end,
})
vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = { "go", "gomod", "gowork", "make" },
	callback = function()
		vim.opt_local.expandtab = false
		vim.opt_local.shiftwidth = 0
		vim.opt_local.softtabstop = 0
		vim.opt_local.tabstop = 4
	end,
})
vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = { "markdown", "text", "gitcommit" },
	callback = function()
		vim.opt_local.spell = true
	end,
})
