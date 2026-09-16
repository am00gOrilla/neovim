return {
	"junegunn/fzf.vim",
	cmd = "FZFFilesProximity",
	dependencies = { "junegunn/fzf" },
	config = function()
		local running
		vim.api.nvim_create_user_command("FZFFilesProximity", function()
			if running then
				return
			end
			if vim.fn.executable("rg") ~= 1 or vim.fn.executable("fzf") ~= 1 then
				vim.notify("File search requires rg and fzf", vim.log.levels.ERROR)
				return
			end
			local root = require("dev").root()
			local file = vim.api.nvim_buf_get_name(0)
			local current = file ~= "" and vim.fs.dirname(file) or root
			local current_parts = vim.split(current:sub(#root + 2), "/", { trimempty = true })
			-- Run discovery asynchronously; argv handles spaces and shell characters.
			running = vim.system(
				{
					"rg",
					"--files",
					"--hidden",
					"-g",
					"!.git",
					"-g",
					"!node_modules",
					"-g",
					"!.venv",
					"-g",
					"!venv",
					"-g",
					"!__pycache__",
				},
				{ cwd = root, text = true },
				vim.schedule_wrap(function(result)
					running = nil
					if result.code > 1 then
						vim.notify(result.stderr, vim.log.levels.ERROR)
						return
					end
					local items = {}
					for _, path in ipairs(vim.split(result.stdout or "", "\n", { trimempty = true })) do
						local dir = vim.fs.dirname(path)
						local parts = vim.split(dir == "." and "" or dir, "/", { trimempty = true })
						local common = 0
						for i = 1, math.min(#parts, #current_parts) do
							if parts[i] ~= current_parts[i] then
								break
							end
							common = i
						end
						items[#items + 1] = { path = path, distance = #parts + #current_parts - 2 * common }
					end
					table.sort(items, function(a, b)
						if a.distance ~= b.distance then
							return a.distance < b.distance
						end
						return a.path < b.path
					end)
					vim.fn["fzf#run"](vim.fn["fzf#wrap"]({
						source = vim.tbl_map(function(item)
							return item.path
						end, items),
						sink = function(path)
							vim.cmd.edit(vim.fn.fnameescape(root .. "/" .. path))
						end,
						options = "--prompt='Project files > '",
					}))
				end)
			)
		end, { desc = "Find project files by proximity" })
	end,
}
