-- stylua: ignore start

-- toggle relative line numbers
vim.keymap.set("n", "<leader>rl", function()
    vim.opt.relativenumber = not vim.opt.relativenumber:get()
end, { desc = "Toggle relative line numbers" })

-- Reload all buffers
vim.keymap.set("n", "<leader>re", ":bufdo e<CR>", { desc = "Reload all open files" })

-- yank/paste to clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set({ "n", "v" }, "<leader>p", [["+p]])

-- General
vim.keymap.set("n", "<Esc>", ":nohlsearch<cr>")
vim.keymap.set("i", "jj", "<Esc>")

-- Toggle to the previously edited buffer
vim.keymap.set("n", "<leader><leader>", "<cmd>b#<CR>", { desc = "Switch to last buffer" })

-- Switch between splits
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to the left split" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to the right split" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to the upper split" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to the lower split" })

-- ATTENTION: here are the plugin keymaps

-- bufferline
vim.keymap.set("n", "<leader>bs", "<Cmd>BufferLinePick<CR>", { silent = true })
vim.keymap.set("n", "<Tab>", "<Cmd>BufferLineCycleNext<CR>", { silent = true })
vim.keymap.set("n", "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", { silent = true })
-- vim.keymap.set("n", "<leader>bh", "<Cmd>BufferLineMovePrev<CR>", { silent = true })
-- vim.keymap.set("n", "<leader>bl", "<Cmd>BufferLineMoveNext<CR>", { silent = true })
vim.keymap.set("n", "<leader>bx", "<Cmd>BufferLinePickClose<CR>", { silent = true })
vim.keymap.set("n", "<leader>bxa", "<Cmd>BufferLineCloseOthers<CR>", { silent = true })

vim.keymap.set("n", "bl", function()
  require("bufferline").move(vim.v.count1)
end, { silent = true, desc = "Move buffer right" })

vim.keymap.set("n", "bh", function()
  require("bufferline").move(-vim.v.count1)
end, { silent = true, desc = "Move buffer left" })

for i = 1, 9 do
  vim.keymap.set("n", "<leader>" .. i, function()
    require("bufferline").go_to_buffer(i, true)
  end, { desc = "Go to buffer " .. i })
end

-- Comments
vim.keymap.set("n", "<C-_>", function()
    require("Comment.api").toggle.linewise.current()
end, { desc = "Toggle single-line comment" })
vim.keymap.set(
    "v",
    "<C-_>",
    "<ESC><CMD>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
    { desc = "Toggle multi-line comment" }
)

-- debugging
vim.keymap.set("n", "<F2>", function() require("dap").step_into() end, { desc = "Debugger step into" })
vim.keymap.set("n", "<F3>", function() require("dap").step_over() end, { desc = "Debugger step over" })
vim.keymap.set("n", "<F4>", function() require("dap").step_out() end, { desc = "Debugger step out" })
vim.keymap.set("n", "<F5>", function() require("dap").continue() end, { desc = "Debugger continue" })
vim.keymap.set("n", "<Leader>b", function() require("dap").toggle_breakpoint() end, { desc = "Debugger toggle breakpoint" })
vim.keymap.set("n", "<F6>", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end,
    { desc = "Debugger set conditional breakpoint" })
vim.keymap.set("n", "<F7>", function() require("dap").terminate() end, { desc = "Debugger reset" })
vim.keymap.set("n", "<F8>", function() require("dap").run_last() end, { desc = "Debugger run last" })

-- Flash
vim.keymap.set({ "n", "x", "o" }, "s", function() require("flash").jump() end, { desc = "Flash" })
vim.keymap.set({ "n", "x", "o" }, "S", function() require("flash").treesitter() end, { desc = "Flash Treesitter" })
vim.keymap.set("o", "r", function() require("flash").remote() end, { desc = "Remote Flash" })
vim.keymap.set({ "o", "x" }, "R", function() require("flash").treesitter_search() end, { desc = "Treesitter Search" })
vim.keymap.set("c", "<c-s>", function() require("flash").toggle() end, { desc = "Toggle Flash Search" })

-- Git
vim.keymap.set("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<cr>")
vim.keymap.set("n", "<leader>gb", "<cmd>Git blame<cr>")
vim.keymap.set("n", "<leader>gl", "<cmd>Git log --oneline --graph --decorate --all<cr>")
vim.keymap.set("n", "gfd", "<cmd>Gitsigns diffthis<CR>", { desc = "Git: diff current file" })

-- LSP
vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
vim.keymap.set("n", "<leader>gdv", "<cmd>rightbelow vsplit | lua vim.lsp.buf.definition()<CR>",
    { desc = "Go to definition (vertical split on right)" })
vim.keymap.set("n", "<leader>gds", "<cmd>split | lua vim.lsp.buf.definition()<CR>",
    { desc = "Go to definition (horizontal split)" })
vim.keymap.set("n", "<leader>gdp", "<cmd>Lspsaga peek_definition<CR>", { desc = "Peek definition" })
vim.keymap.set("n", "<leader>qo", ":only<CR>", { desc = "Close all splits except current" })
vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})
vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, { desc = "Show signature help" })

-- Copy diagnostics to system clipboard
vim.keymap.set("n", "<leader>cd", function()
  local diag = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
  if #diag == 0 then
    vim.notify("No diagnostics on this line", vim.log.levels.INFO)
    return
  end
  local messages = {}
  for _, d in ipairs(diag) do
    table.insert(messages, d.message)
  end
  vim.fn.setreg("+", table.concat(messages, "\n"))
  vim.notify("Diagnostics copied to clipboard")
end, { desc = "Copy diagnostics to clipboard" })


-- neo-tree
vim.keymap.set("n", "<leader>e", function() require("explorer").focus() end, { desc = "Focus explorer / editor" })
vim.keymap.set("n", "<C-b>", function() require("explorer").toggle() end, { desc = "Show / hide explorer" })
vim.keymap.set("n", "<leader>E", ":Neotree reveal<CR>", { desc = "Explorer NeoTree (Reveal File)" })
vim.keymap.set("n", "<leader>nf", ":Neotree focus filesystem left<CR>", { desc = "Focus filesystem explorer" })
vim.keymap.set("n", "<leader>gs", ":Neotree git_status<CR>", { desc = "Git Status NeoTree" })

-- noice
vim.keymap.set("n", "<leader>nd", ":NoiceDismiss<CR>", { desc = "Dismiss Noice Message" })
vim.keymap.set("n", "<leader>nl", ":Telescope noice<CR>", { desc = "List All Noice Messages" })

-- ufo
vim.keymap.set('n', 'zR', function() require('ufo').openAllFolds() end)
vim.keymap.set('n', 'zM', function() require('ufo').closeAllFolds() end)

-- Persisted
vim.keymap.set("n", "<leader>ss", ":SessionSave<CR>", { desc = "Save Session" })
vim.keymap.set("n", "<leader>sd", ":SessionDelete<CR>", { desc = "Delete Session" })
vim.keymap.set("n", "<leader>sl", ":Telescope persisted<CR>", { desc = "Delete Session" })

-- Rustaceanvim
vim.keymap.set("n", "<leader>rdt", "<cmd>RustLsp testables<CR>", { desc = "Debugger testables" })

-- tabular (csv view)
vim.keymap.set("n", "<leader>csv", ":Tabularize /,<CR>", { desc = "Tabularize by comma" })
vim.keymap.set("n", "<leader>tsv", ":Tabularize /\\t/<CR>", { desc = "Tabularize by tab" })

-- telescope
vim.keymap.set("n", "<leader>ff", function() require("telescope.builtin").find_files({ cwd = require("dev").root() }) end, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", function() require("telescope.builtin").live_grep({ cwd = require("dev").root() }) end, { desc = "Telescope live grep" })

-- theme
vim.keymap.set("n", "<leader>tsm", "<cmd>Themery<cr>", { desc = "Theme switcher menu" })
vim.keymap.set("n", "<leader>tn", "<cmd>ThemeryNext<cr>", { desc = "Next theme" })
vim.keymap.set("n", "<leader>tp", "<cmd>ThemeryPrev<cr>", { desc = "Previous theme" })

-- Todo comment
vim.keymap.set("n", "<leader>tt", "<cmd>TodoTelescope<cr>")
vim.keymap.set("n", "<leader>tl", "<cmd>TodoLocList<cr>")

-- toggleterminal
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode." })
vim.keymap.set("n", "<leader>th", ":ToggleTerm direction=horizontal<CR>", { desc = "Open terminal below." })
vim.keymap.set("n", "<leader>tf", ":ToggleTerm direction=float<CR>", { desc = "Open a floting terminal." })
vim.keymap.set("n", "<leader>tst", ":ToggleTermSendCurrentLine<CR>", { desc = "Send current line to terminal." })

-- UndoTree
vim.keymap.set("n", "<leader>u", ":UndotreeToggle<CR>", { desc = "Toggle Undo Tree" })

-- python venv selector
vim.keymap.set("n", "<leader>vs", "<cmd>VenvSelect<cr>", { desc = "Open python venv selector." })
vim.keymap.set("n", "<leader>vc", "<cmd>VenvSelectCached<cr>", { desc = "Select previously used venv for this project." })

-- File opener
vim.keymap.set("n", "<C-p>", ":FZFFilesProximity<CR>", { noremap = true, silent = true })

-- focus the floating window with the highest z-index
vim.keymap.set('n', '<leader>z', function()
  local top_win, top_z = nil, -1
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local cfg = vim.api.nvim_win_get_config(win)
    if cfg.relative ~= '' and (cfg.zindex or 0) > top_z then
      top_win, top_z = win, cfg.zindex or 0
    end
  end
  if top_win then vim.api.nvim_set_current_win(top_win) end
end, { desc = 'Focus topmost floating window' })

-- Development workflow
vim.keymap.set({ "n", "v" }, "<leader>gf", function()
    require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format buffer or selection" })
vim.keymap.set("n", "rf", function() require("conform").format({ async = true }) end, { desc = "Format buffer" })
vim.keymap.set("n", "<leader>uf", function()
    vim.b.disable_autoformat = not vim.b.disable_autoformat
    vim.notify("Format on save: " .. (vim.b.disable_autoformat and "off" or "on"))
end, { desc = "Toggle format on save (buffer)" })
vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename symbol" })
vim.keymap.set("n", "gr", function() require("telescope.builtin").lsp_references() end, { desc = "Find references" })
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
vim.keymap.set("n", "<leader>fd", function() require("telescope.builtin").diagnostics() end, { desc = "Find diagnostics" })
vim.keymap.set("n", "<leader>fs", function() require("telescope.builtin").lsp_document_symbols() end, { desc = "Find document symbols" })
vim.keymap.set("n", "<leader>ce", vim.diagnostic.open_float, { desc = "Show diagnostic" })
vim.keymap.set("n", "<leader>du", function() require("dap"); require("dapui").toggle() end, { desc = "Toggle debugger UI" })
vim.keymap.set("n", "<leader>dl", function()
    require("dap")
    require("dap.ext.vscode").load_launchjs(require("dev").root() .. "/.vscode/launch.json")
end, { desc = "Load project launch.json" })
for action, key in pairs({ run = "r", test = "t", build = "b" }) do
    vim.api.nvim_create_user_command("Dev" .. action:sub(1, 1):upper() .. action:sub(2), function()
        require("dev").task(action)
    end, {})
    vim.keymap.set("n", "<leader>m" .. key, function() require("dev").task(action) end, { desc = "Project " .. action })
end

-- stylua: ignore end
