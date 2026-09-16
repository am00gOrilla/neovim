-- Run with the real config: nvim --headless -i NONE -c 'luafile tests/explorer.lua'
require("persisted").stop()
vim.o.columns = 180
vim.o.lines = 50
local tmp = vim.fn.tempname()
vim.fn.mkdir(tmp .. "/nested", "p")
tmp = vim.uv.fs_realpath(tmp)
vim.fn.writefile({ "first editor" }, tmp .. "/main.txt")
vim.fn.writefile({ "second editor" }, tmp .. "/second.txt")
vim.fn.writefile({ "nested file" }, tmp .. "/nested/other.txt")

local function press(key)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), "mxt", false)
end
local function state()
	return require("neo-tree.sources.manager").get_state("filesystem")
end
local function wait_for_tree()
	assert(
		vim.wait(3000, function()
			local tree = state()
			return tree.winid and vim.api.nvim_win_is_valid(tree.winid) and tree.tree ~= nil
		end, 25),
		"Explorer did not open"
	)
	return state().winid
end
local function check_sidebar(win, buf)
	assert(vim.api.nvim_win_is_valid(win), "Focus change closed the sidebar")
	assert(vim.api.nvim_win_get_buf(win) == buf, "Focus change replaced the sidebar buffer")
	assert(vim.bo[buf].filetype == "neo-tree", "Sidebar became a code buffer")
end

local ok, err = pcall(function()
	vim.cmd.edit(vim.fn.fnameescape(tmp .. "/main.txt"))
	vim.cmd.vsplit(vim.fn.fnameescape(tmp .. "/second.txt"))
	local editor = vim.api.nvim_get_current_win()
	local code_buf = vim.api.nvim_get_current_buf()
	press("<Space>e")
	local tree = wait_for_tree()
	local tree_buf = vim.api.nvim_win_get_buf(tree)
	assert(vim.api.nvim_get_current_win() == tree, "Space e did not focus the explorer")
	for _ = 1, 5 do
		press("<Space>e")
		assert(vim.api.nvim_get_current_win() == editor, "Did not return to the last editor split")
		check_sidebar(tree, tree_buf)
		press("<Space>e")
		assert(vim.api.nvim_get_current_win() == tree, "Did not reuse the existing sidebar")
		check_sidebar(tree, tree_buf)
	end
	for _, key in ipairs({ "<Tab>", "<S-Tab>", "<Esc>", "<C-l>" }) do
		press(key)
		assert(vim.api.nvim_get_current_win() == editor, key .. " did not return to the editor")
		assert(vim.api.nvim_win_get_buf(editor) == code_buf, key .. " changed the code buffer")
		check_sidebar(tree, tree_buf)
		press("<Space>e")
	end
	-- The actual Enter mapping should open the selected file in the last editor.
	require("neo-tree.ui.renderer").focus_node(state(), tmp .. "/main.txt")
	press("<CR>")
	assert(vim.api.nvim_get_current_win() == editor, "Enter opened a file in the wrong split")
	assert(vim.api.nvim_buf_get_name(0) == tmp .. "/main.txt", "Enter did not open the selected file")
	check_sidebar(tree, tree_buf)

	press("<C-b>")
	assert(not vim.api.nvim_win_is_valid(tree), "Ctrl-b did not hide the sidebar")
	assert(vim.api.nvim_get_current_win() == editor, "Hiding the sidebar moved editor focus")
	press("<C-b>")
	tree = wait_for_tree()
	assert(
		vim.wait(1000, function()
			return vim.api.nvim_get_current_win() == editor
		end, 25),
		"Showing the sidebar stole focus"
	)
	press("<Space>e")
	press("<C-b>")
	assert(not vim.api.nvim_win_is_valid(tree), "Ctrl-b inside the sidebar did not hide it")
	assert(vim.api.nvim_get_current_win() == editor, "Hiding from the tree did not return to the editor")
	print("Explorer focus, last editor split, file opening, Tab/Esc, and visibility checks passed")
end)

vim.fn.delete(tmp, "rf")
if not ok then
	print(err)
	vim.cmd("cquit 1")
else
	vim.cmd("qa!")
end
