return {
    {
        "dhruvasagar/vim-table-mode",
        ft = { "markdown" },
        init = function()
            vim.g.table_mode_corner = "|"
        end,
    },
    {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
            heading = {
                sign = false,
                icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
            },
            checkbox = {
                unchecked = { icon = "󰄱 " },
                checked = { icon = "󰱒 " },
            },
            code = {
                sign = false,
                width = "block",
                right_pad = 1,
            },
        },
    },
}
