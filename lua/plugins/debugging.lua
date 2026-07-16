return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "rcarriga/nvim-dap-ui",
            "mfussenegger/nvim-dap-python",
            "theHamsta/nvim-dap-virtual-text",
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")
            local dap_python = require("dap-python")

            -- Setup DAP UI and virtual text
            require("dapui").setup({})

            -- Initialize Python adapter using 'python3'
            dap_python.setup("python3")

            local mason_path = vim.fn.stdpath("data") .. "/mason"

            -- Go adapter: uses existing dlv binary (install via: go install github.com/go-delve/delve/cmd/dlv@latest)
            dap.adapters.delve = {
                type = "server",
                port = "${port}",
                executable = {
                    command = "dlv",
                    args = { "dap", "-l", "127.0.0.1:${port}" },
                },
            }
            dap.configurations.go = {
                {
                    type = "delve",
                    name = "Debug",
                    request = "launch",
                    program = "${file}",
                },
                {
                    type = "delve",
                    name = "Debug test",
                    request = "launch",
                    program = "${file}",
                    mode = "test",
                },
                {
                    type = "delve",
                    name = "Debug test (package)",
                    request = "launch",
                    program = "./${relativeFileDirname}",
                    mode = "test",
                },
            }

            -- C/C++ adapter via codelldb (Mason installs this)
            local codelldb_path = mason_path .. "/packages/codelldb/extension/adapter/codelldb"
            local liblldb_path = mason_path .. "/packages/codelldb/extension/lldb/lib/liblldb.dylib"
            dap.adapters.codelldb = {
                type = "server",
                port = "${port}",
                executable = {
                    command = codelldb_path,
                    args = { "--liblldb", liblldb_path, "--port", "${port}" },
                },
            }
            dap.configurations.c = {
                {
                    type = "codelldb",
                    name = "Debug (codelldb)",
                    request = "launch",
                    program = function()
                        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                    end,
                    cwd = "${workspaceFolder}",
                    terminal = "integrated",
                },
            }
            dap.configurations.cpp = dap.configurations.c
            dap.configurations.objc = dap.configurations.c

            vim.fn.sign_define("DapBreakpoint", {
                text = "",
                texthl = "DiagnosticSignError",
                linehl = "",
                numhl = "",
            })
            vim.fn.sign_define("DapBreakpointRejected", {
                text = "",
                texthl = "DiagnosticSignError",
                linehl = "",
                numhl = "",
            })
            vim.fn.sign_define("DapStopped", {
                text = "",
                texthl = "DiagnosticSignWarn",
                linehl = "Visual",
                numhl = "DiagnosticSignWarn",
            })

            dap.listeners.before.attach.dapui_config = function() dapui.open() end
            dap.listeners.before.launch.dapui_config = function() dapui.open() end
            dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
            dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

            dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
        end,
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = {
            "mfussenegger/nvim-dap"
        },
        config = function()
            require("dapui").setup()
        end,
    },
}
