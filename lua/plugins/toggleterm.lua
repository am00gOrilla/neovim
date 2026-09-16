return {
    "akinsho/toggleterm.nvim",
    cmd = { "ToggleTerm", "ToggleTermSendCurrentLine" },
    keys = { { [[<c-\>]], "<cmd>ToggleTerm<cr>", mode = { "n", "t" }, desc = "Toggle terminal" } },
    config = function()
        require("toggleterm").setup({
            size = 15,
            open_mapping = [[<c-\>]],
            hide_numbers = true,
            shade_terminals = true,
            shading_factor = 10,
            persist_size = true,
            direction = "horizontal",
            float_opts = {
                border = "curved",
                winblend = 0,
                highlights = {
                    border = "Normal",
                    background = "Normal"
                }
            }
        })
    end
}
