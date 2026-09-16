-- Run from the config root: nvim --headless -u NONE -l tests/dev.lua
package.path = vim.fn.getcwd() .. "/lua/?.lua;" .. package.path
vim.env.VIRTUAL_ENV = nil
vim.env.CONDA_PREFIX = nil
local original_python = vim.fn.exepath("python3")
local dev = dofile("lua/dev.lua")
local tmp = vim.fn.tempname()
vim.fn.mkdir(tmp, "p")
tmp = vim.uv.fs_realpath(tmp)
local count = 0
local function eq(actual, expected, label)
	assert(vim.deep_equal(actual, expected), label .. ": " .. vim.inspect(actual))
	count = count + 1
end
local function write(path, lines)
	vim.fn.mkdir(vim.fs.dirname(tmp .. path), "p")
	vim.fn.writefile(lines or {}, tmp .. path)
end
local function executable(path)
	write(path, { "#!/bin/sh", "exit 0" })
	vim.uv.fs_chmod(tmp .. path, 493)
end
local function open(path, ft)
	vim.cmd.edit(vim.fn.fnameescape(tmp .. path))
	vim.bo.filetype = ft
end
local called
-- Validate commands and their working directories without running project code.
dev.terminal = function(argv, root)
	called = { argv, root }
end
vim.ui.select = function(items, _, callback)
	callback(items[1])
end
local ok, err = pcall(function()
	write("/python/pyproject.toml", { "[project]" })
	write("/python/src/main.py", { "print('hello')" })
	executable("/python/.venv/bin/python")
	executable("/alternate/bin/python")
	open("/python/src/main.py", "python")
	eq(dev.root(), tmp .. "/python", "Python root from nested source")
	eq(dev.python(), tmp .. "/python/.venv/bin/python", "Project venv detection")
	vim.b.venv_selector_last_python = tmp .. "/alternate/bin/python"
	eq(dev.python(), tmp .. "/alternate/bin/python", "Explicit selection takes priority")
	dev.task("run")
	eq(
		called,
		{ { tmp .. "/alternate/bin/python", tmp .. "/python/src/main.py" }, tmp .. "/python" },
		"Python run uses selection"
	)
	dev.task("test")
	eq(called[1], { tmp .. "/alternate/bin/python", "-m", "pytest" }, "pytest uses selection")

	vim.b.venv_selector_last_python = nil
	vim.fn.delete(tmp .. "/python/.venv/bin/python")
	vim.uv.fs_symlink(tmp .. "/missing/python", tmp .. "/python/.venv/bin/python")
	local warnings = {}
	local notify = vim.notify
	vim.notify = function(message)
		table.insert(warnings, message)
	end
	eq(dev.python(), original_python, "Broken project interpreter is not selected")
	dev.python()
	eq(#warnings, 1, "Broken environment warns once instead of silently falling back")
	assert(warnings[1]:find("uv sync", 1, true), "Warning explains how to repair a uv environment")
	vim.notify = notify

	write("/other/.git", { "gitdir: ../worktrees/other" })
	write("/other/nested/tool.py", {})
	open("/other/nested/tool.py", "python")
	vim.env.VIRTUAL_ENV = tmp .. "/alternate"
	vim.env.PATH = tmp .. "/alternate/bin:" .. vim.env.PATH
	eq(dev.root(), tmp .. "/other", "Git worktree file recognized")
	eq(dev.python(), original_python, "Environment does not leak between projects")

	write("/node/package.json", { '{"packageManager":"pnpm@10.0.0","scripts":{"dev":"node main.js"}}' })
	write("/node/src/main.ts", {})
	open("/node/src/main.ts", "typescript")
	dev.task("run")
	eq(called, { { "pnpm", "run", "dev" }, tmp .. "/node" }, "Node script uses package manager")
	dev.task("build")
	eq(called[1], { "pnpm", "run", "build" }, "Node build command")
	write("/node/package.json", { "{}" })
	write("/node/yarn.lock", {})
	dev.task("test")
	eq(called[1], { "yarn", "run", "test" }, "Lockfile fallback")

	write("/go/go.mod", { "module example.com/test" })
	write("/go/cmd/app/main.go", {})
	open("/go/cmd/app/main.go", "go")
	dev.task("run")
	eq(called, { { "go", "run", "." }, tmp .. "/go/cmd/app" }, "Go runs whole package")
	dev.task("test")
	eq(called, { { "go", "test", "./..." }, tmp .. "/go" }, "Go tests whole module")

	write("/cpp/CMakeLists.txt", {})
	write("/cpp/src/main.cpp", {})
	open("/cpp/src/main.cpp", "cpp")
	vim.b.cmake_build_dir = "out/debug"
	dev.task("build")
	eq(called, { { "cmake", "--build", "out/debug" }, tmp .. "/cpp" }, "CMake build directory override")
	dev.task("test")
	eq(called[1], { "ctest", "--test-dir", "out/debug", "--output-on-failure" }, "CTest directory override")
end)
vim.fn.delete(tmp, "rf")
if not ok then
	error(err)
end
print(count .. " environment/task checks passed")
