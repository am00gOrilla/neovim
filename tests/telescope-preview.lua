-- Run with the real config: nvim --headless -i NONE -c 'luafile tests/telescope-preview.lua'
require("persisted").stop()
vim.o.columns = 160
vim.o.lines = 50

local tmp = vim.fn.tempname()
vim.fn.mkdir(tmp, "p")
local cases = {
	{ "package.json", '{"name":"preview-test"}', "json" },
	{ "main.py", 'print("preview-test")', "python" },
	{ "main.ts", 'const name: string = "preview-test";', "typescript" },
	{ "main.go", 'package main\nfunc main() { println("preview-test") }', "go" },
	{ "main.cpp", "int main() { return 0; }", "cpp" },
}
local errors = {}
local notify = vim.notify
vim.notify = function(message, level, opts)
	if level == vim.log.levels.ERROR then
		errors[#errors + 1] = tostring(message)
	end
	return notify(message, level, opts)
end

local ok, err = pcall(function()
	for i, case in ipairs(cases) do
		local directory = tmp .. "/" .. i
		vim.fn.mkdir(directory, "p")
		vim.fn.writefile(vim.split(case[2], "\n"), directory .. "/" .. case[1])
		require("telescope.builtin").find_files({
			cwd = directory,
			layout_strategy = "horizontal",
			layout_config = { preview_cutoff = 1 },
		})
		local prompt = vim.api.nvim_get_current_buf()
		local picker = require("telescope.actions.state").get_current_picker(prompt)
		assert(
			vim.wait(5000, function()
				local preview = picker.previewer and picker.previewer.state
				local buf = preview and preview.bufnr
				return buf
					and vim.api.nvim_buf_is_valid(buf)
					and vim.treesitter.highlighter.active[buf] ~= nil
					and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == vim.split(case[2], "\n")[1]
			end, 25),
			case[1] .. ": highlighted file preview did not load"
		)
		assert(vim.treesitter.get_parser(picker.previewer.state.bufnr):lang() == case[3], case[1])
		require("telescope.actions").close(prompt)
		print(case[1] .. ": picker preview and Tree-sitter highlighting OK")
	end
	assert(#errors == 0, table.concat(errors, "\n"))
end)

vim.notify = notify
vim.fn.delete(tmp, "rf")
if not ok then
	print(err)
	vim.cmd("cquit 1")
else
	vim.cmd("qa!")
end
