-- Run from the config root: nvim --headless -u NONE -l tests/python-lsp.lua
package.path = vim.fn.getcwd() .. "/lua/?.lua;" .. package.path
local configs = {}
vim.lsp.config = function(name, config)
	configs[name] = config
end
vim.lsp.enable = function() end
package.loaded["blink.cmp"] = {
	get_lsp_capabilities = function()
		return {}
	end,
}
package.loaded["mason-lspconfig"] = { setup = function() end }
local spec = dofile("lua/plugins/lsp-config.lua")
spec[2].config()
local python = vim.fn.exepath("python3")
local selected = vim.fn.exepath("nvim")
package.loaded.dev = {
	python = function()
		return python
	end,
}
local count = 0
local function check(config, expected, label)
	configs.pyrefly.before_init({}, config)
	assert(config.init_options and config.init_options.pythonPath == expected, label)
	assert(config.settings.python.pythonPath == expected, "Settings and initialization must agree")
	count = count + 1
end
check({ root_dir = "/project" }, python, "Project interpreter is sent during initialization")
check(
	{ root_dir = "/project", settings = { python = { pythonPath = selected } } },
	selected,
	"VenvSelect interpreter wins when restarting the language server"
)
local invalid = {
	root_dir = "/project",
	settings = { python = { pythonPath = "/missing/python" } },
	init_options = { pythonPath = "/stale/python", pyrefly = { diagnosticMode = "openFilesOnly" } },
}
check(invalid, python, "Invalid cached interpreter falls back to project selection")
assert(invalid.init_options.pyrefly.diagnosticMode == "openFilesOnly", "Other initialization settings preserved")
print(count .. " Python LSP checks passed")
