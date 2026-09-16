local M = {}
local warned_venvs = {}
-- Capture the shell environment before venv-selector changes it for a buffer.
local shell_venv = vim.env.VIRTUAL_ENV or vim.env.CONDA_PREFIX
local shell_python = vim.fn.exepath("python3")
if shell_python == "" then
	shell_python = vim.fn.exepath("python")
end
local markers = {
	python = { "pyrefly.toml", "pyproject.toml", "setup.py", "requirements.txt", ".venv" },
	go = { "go.mod", "go.work" },
	javascript = { "package.json" },
	typescript = { "package.json" },
	javascriptreact = { "package.json" },
	typescriptreact = { "package.json" },
	c = { "CMakeLists.txt", "Makefile", "compile_commands.json" },
	cpp = { "CMakeLists.txt", "Makefile", "compile_commands.json" },
}

function M.root(bufnr)
	bufnr = bufnr or 0
	local filename = vim.api.nvim_buf_get_name(bufnr)
	local start = filename ~= "" and vim.fs.dirname(filename) or vim.fn.getcwd()
	return vim.fs.root(start, markers[vim.bo[bufnr].filetype] or {}) or vim.fs.root(start, ".git") or start
end

function M.python(bufnr, root)
	bufnr = bufnr or 0
	root = root or M.root(bufnr)
	local selected = vim.b[bufnr].venv_selector_last_python
	if selected and M.root(bufnr) == root and vim.fn.executable(selected) == 1 then
		return selected
	end
	for _, env in ipairs({ root .. "/.venv", root .. "/venv", shell_venv or "" }) do
		if env ~= "" then
			for _, suffix in ipairs({ "/bin/python", "/Scripts/python.exe" }) do
				if vim.fn.executable(env .. suffix) == 1 then
					return env .. suffix
				end
			end
			if
				not warned_venvs[env]
				and (vim.uv.fs_lstat(env .. "/bin/python") or vim.uv.fs_stat(env .. "/pyvenv.cfg"))
			then
				warned_venvs[env] = true
				vim.notify(
					"Broken Python environment: "
						.. env
						.. ". Recreate it and install dependencies (uv sync for uv projects).",
					vim.log.levels.WARN
				)
			end
		end
	end
	return shell_python ~= "" and shell_python or "python"
end

local function node_manager(root)
	local ok, package = pcall(function()
		return vim.json.decode(table.concat(vim.fn.readfile(root .. "/package.json"), "\n"))
	end)
	local manager = ok
		and type(package) == "table"
		and type(package.packageManager) == "string"
		and package.packageManager:match("^([^@]+)@")
	if vim.tbl_contains({ "npm", "pnpm", "yarn", "bun" }, manager) then
		return manager
	end
	for _, item in ipairs({
		{ "pnpm-lock.yaml", "pnpm" },
		{ "yarn.lock", "yarn" },
		{ "bun.lock", "bun" },
		{ "bun.lockb", "bun" },
	}) do
		if vim.uv.fs_stat(root .. "/" .. item[1]) then
			return item[2]
		end
	end
	return "npm"
end

function M.terminal(argv, root)
	if vim.fn.executable(argv[1]) ~= 1 then
		vim.notify("Missing executable: " .. argv[1], vim.log.levels.ERROR)
		return
	end
	vim.cmd("botright 15new")
	vim.bo.bufhidden = "hide"
	vim.fn.jobstart(argv, { term = true, cwd = root })
	vim.cmd("startinsert")
end

function M.task(action)
	if vim.bo.buftype ~= "" then
		vim.notify("Run development tasks from a source buffer", vim.log.levels.WARN)
		return
	end
	vim.cmd("update")
	local root, ft, file = M.root(), vim.bo.filetype, vim.api.nvim_buf_get_name(0)
	local argv
	if ft == "python" then
		argv = action == "run" and { M.python(), file } or action == "test" and { M.python(), "-m", "pytest" }
	elseif ft == "go" then
		-- Use the whole package, including sibling source files.
		local package_dir = vim.fs.dirname(file)
		argv = action == "run" and { "go", "run", "." }
			or action == "test" and { "go", "test", "./..." }
			or { "go", "build", "./..." }
		if action == "run" then
			root = package_dir
		end
	elseif ft:match("^[jt]avascript") or ft:match("^typescript") then
		local manager = node_manager(root)
		if action == "run" then
			local ok, package = pcall(function()
				return vim.json.decode(table.concat(vim.fn.readfile(root .. "/package.json"), "\n"))
			end)
			local scripts = ok
					and type(package) == "table"
					and type(package.scripts) == "table"
					and vim.tbl_keys(package.scripts)
				or {}
			table.sort(scripts)
			if #scripts == 0 then
				vim.notify("No package.json scripts found", vim.log.levels.WARN)
				return
			end
			vim.ui.select(scripts, { prompt = "Run package script:" }, function(script)
				if script then
					M.terminal({ manager, "run", script }, root)
				end
			end)
			return
		end
		argv = { manager, "run", action }
	elseif ft == "c" or ft == "cpp" then
		local build = vim.b.cmake_build_dir or "build"
		argv = action == "build" and { "cmake", "--build", build }
			or action == "test" and { "ctest", "--test-dir", build, "--output-on-failure" }
	end
	if argv then
		M.terminal(argv, root)
	else
		vim.notify("No " .. action .. " task for " .. ft .. "; use the terminal or debugger", vim.log.levels.INFO)
	end
end

return M
