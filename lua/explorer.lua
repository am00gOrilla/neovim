local M = {}

local function sidebar()
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.bo[buf].filetype == "neo-tree" and vim.api.nvim_win_get_config(win).relative == "" then
			return win
		end
	end
end

local function is_editor(win)
	if not win or not vim.api.nvim_win_is_valid(win) then
		return false
	end
	local buf = vim.api.nvim_win_get_buf(win)
	return vim.api.nvim_win_get_tabpage(win) == vim.api.nvim_get_current_tabpage()
		and vim.api.nvim_win_get_config(win).relative == ""
		and vim.bo[buf].buftype == ""
		and vim.bo[buf].filetype ~= "neo-tree"
end

function M.editor()
	local remembered = vim.t.explorer_editor_win
	if is_editor(remembered) then
		vim.api.nvim_set_current_win(remembered)
		return
	end
	local tree = package.loaded["neo-tree"]
	local prior = tree
		and tree.get_prior_window({
			["neo-tree"] = true,
			nofile = true,
			terminal = true,
			prompt = true,
			qf = true,
			help = true,
		})
	if is_editor(prior) then
		vim.api.nvim_set_current_win(prior)
		return
	end
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if is_editor(win) then
			vim.api.nvim_set_current_win(win)
			return
		end
	end
	-- If the last editor was closed, create one without replacing the sidebar.
	vim.cmd("rightbelow vnew")
end

local function open(action)
	local path = vim.api.nvim_buf_get_name(0)
	require("neo-tree.command").execute({
		action = action,
		source = "filesystem",
		position = "left",
		dir = require("dev").root(),
		reveal_file = vim.fn.filereadable(path) == 1 and path or nil,
	})
end

function M.focus()
	if vim.bo.filetype == "neo-tree" then
		M.editor()
		return
	end
	local win = sidebar()
	if win then
		-- Moving focus must not rebuild the tree or discard its scroll/expansion state.
		vim.api.nvim_set_current_win(win)
	else
		open("focus")
	end
end

function M.toggle()
	local win = sidebar()
	if win then
		local source = vim.b[vim.api.nvim_win_get_buf(win)].neo_tree_source or "filesystem"
		if vim.api.nvim_get_current_win() == win then
			M.editor()
		end
		require("neo-tree.command").execute({ action = "close", source = source, position = "left" })
	else
		open("show")
	end
end

local function remember_editor()
	local win = vim.api.nvim_get_current_win()
	if is_editor(win) then
		vim.t.explorer_editor_win = win
	end
end

-- Capture the first editor before Neo-tree is lazy-loaded, then track each tab's
-- most recently used code window. Terminals and floating panels do not replace it.
remember_editor()
-- A new split temporarily contains the editor's buffer before Neo-tree replaces
-- it, so record the window we leave instead of mistaking that split for an editor.
vim.api.nvim_create_autocmd("WinLeave", {
	group = vim.api.nvim_create_augroup("ExplorerEditorFocus", { clear = true }),
	callback = remember_editor,
})

return M
