return {
	{
		"mason-org/mason.nvim",
		cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonLog" },
		opts = {},
	},
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"mason-org/mason.nvim",
			"mason-org/mason-lspconfig.nvim",
			"saghen/blink.cmp",
			"b0o/schemastore.nvim",
		},
		config = function()
			-- Mason v2 removed setup handlers. Configure before enabling servers.
			vim.lsp.config("*", {
				capabilities = require("blink.cmp").get_lsp_capabilities(),
				flags = { debounce_text_changes = 150 },
			})
			local servers = {
				lua_ls = {
					settings = {
						Lua = {
							runtime = { version = "LuaJIT" },
							diagnostics = { globals = { "vim" } },
							workspace = { library = { vim.env.VIMRUNTIME }, checkThirdParty = false },
							telemetry = { enable = false },
						},
					},
				},
				pyrefly = {
					before_init = function(_, config)
						config.settings = config.settings or {}
						config.settings.python = config.settings.python or {}
						local python = config.settings.python.pythonPath
						if not python or vim.fn.executable(python) ~= 1 then
							python = require("dev").python(nil, config.root_dir)
						end
						config.settings.python.pythonPath = python
						-- Pyrefly reads pythonPath from initializationOptions at startup.
						-- Refresh it on VenvSelect restarts as well as the first launch.
						config.init_options = config.init_options or {}
						config.init_options.pythonPath = python
					end,
				},
				ruff = {
					init_options = { settings = { lint = { extendSelect = { "I" } } } },
					on_attach = function(client)
						client.server_capabilities.hoverProvider = false
						client.server_capabilities.documentFormattingProvider = false
						client.server_capabilities.documentRangeFormattingProvider = false
					end,
				},
				ts_ls = {},
				eslint = {}, -- Only attaches in an ESLint-configured workspace.
				gopls = {
					settings = {
						gopls = {
							gofumpt = true,
							usePlaceholders = true,
							analyses = { unusedparams = true },
							codelenses = { generate = true, test = true, tidy = true },
						},
					},
				},
				clangd = {
					cmd = { "clangd", "--background-index", "--completion-style=detailed", "--header-insertion=iwyu" },
				},
				jsonls = {
					before_init = function(_, config)
						config.settings.json.schemas = require("schemastore").json.schemas()
					end,
					settings = { json = { validate = { enable = true } } },
				},
				yamlls = {},
				dockerls = {},
				html = {},
				cssls = { settings = { css = { lint = { unknownAtRules = "ignore" } } } },
				tailwindcss = {},
				bashls = {
					handlers = {
						["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
							if
								result
								and result.uri
								and vim.fs.basename(vim.uri_to_fname(result.uri)):match("^%.env")
							then
								result.diagnostics = vim.tbl_filter(function(d)
									return tostring(d.code) ~= "SC2034" and tostring(d.code) ~= "2034"
								end, result.diagnostics or {})
							end
							vim.lsp.handlers["textDocument/publishDiagnostics"](err, result, ctx, config)
						end,
					},
				},
			}
			for name, config in pairs(servers) do
				vim.lsp.config(name, config)
			end
			-- Install explicitly with :MasonToolsInstall; no startup install queue.
			require("mason-lspconfig").setup({ ensure_installed = {}, automatic_enable = false })
			vim.lsp.enable(vim.tbl_keys(servers))
			vim.diagnostic.config({
				underline = true,
				update_in_insert = false,
				severity_sort = true,
				virtual_text = { spacing = 2, source = "if_many" },
				float = { border = "rounded", source = "if_many" },
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = " ",
						[vim.diagnostic.severity.WARN] = " ",
						[vim.diagnostic.severity.HINT] = " ",
						[vim.diagnostic.severity.INFO] = " ",
					},
				},
			})
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		cmd = { "MasonToolsInstall", "MasonToolsInstallSync", "MasonToolsUpdate", "MasonToolsUpdateSync" },
		dependencies = { "mason-org/mason.nvim" },
		opts = {
			ensure_installed = {
				"tree-sitter-cli",
				"lua-language-server",
				"pyrefly",
				"ruff",
				"typescript-language-server",
				"eslint-lsp",
				"gopls",
				"clangd",
				"json-lsp",
				"yaml-language-server",
				"dockerfile-language-server",
				"html-lsp",
				"css-lsp",
				"tailwindcss-language-server",
				"bash-language-server",
				"prettierd",
				"stylua",
				"taplo",
				"buf",
				"sql-formatter",
				"shfmt",
				"shellcheck",
				"goimports",
				"gofumpt",
				"clang-format",
				"codelldb",
				"debugpy",
				"delve",
				"js-debug-adapter",
			},
			auto_update = false,
			run_on_start = false,
			integrations = { ["mason-lspconfig"] = false, ["mason-null-ls"] = false, ["mason-nvim-dap"] = false },
		},
	},
}
