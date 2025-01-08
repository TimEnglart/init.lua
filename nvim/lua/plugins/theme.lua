return {
    { 
        "rose-pine/neovim", 
        name = "rose-pine",
        dir = require("lazy-nix-helper").get_plugin_path("rose-pine"),
        priority = 1000,
        config = function()
            require('rose-pine').setup({
                disable_background = true
            })
            vim.cmd("colorscheme rose-pine")
        end
    },
    {
        'navarasu/onedark.nvim',
        dir = require("lazy-nix-helper").get_plugin_path("onedark.nvim"),
        priority = 1000,
        config = function()
            -- vim.cmd.colorscheme 'onedark'
        end,
    },
    {
        "folke/tokyonight.nvim",
        dir = require("lazy-nix-helper").get_plugin_path("tokyonight.nvim"),
        lazy = false,
        priority = 1000,
        opts = {},
    },
    {
        -- Set lualine as statusline
        'nvim-lualine/lualine.nvim',
        dir = require("lazy-nix-helper").get_plugin_path("lualine.nvim"),
        -- See `:help lualine.txt`
        opts = {
            options = {
            icons_enabled = false,
            theme = 'rose-pine',
            component_separators = '|',
            section_separators = '',
            },
        },
    },
}