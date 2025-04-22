return {
  -- folke
  { 'folke/which-key.nvim', dir = require('lazy-nix-helper').get_plugin_path('which-key.nvim') },
  { 'folke/neoconf.nvim', cmd = 'Neoconf', dir = require('lazy-nix-helper').get_plugin_path('neoconf.nvim') },
  {
    'folke/lazydev.nvim',
    ft = 'lua', -- only load on lua files
    dir = require('lazy-nix-helper').get_plugin_path('lazydev.nvim'),
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },

  -- Git related plugins
  { 'tpope/vim-fugitive', dir = require('lazy-nix-helper').get_plugin_path('vim-fugitive') },
  { 'tpope/vim-rhubarb', dir = require('lazy-nix-helper').get_plugin_path('vim-rhubarb') },

  -- Detect tabstop and shiftwidth automatically
  { 'tpope/vim-sleuth', dir = require('lazy-nix-helper').get_plugin_path('vim-sleuth') },

  { 'mbbill/undotree', dir = require('lazy-nix-helper').get_plugin_path('undotree') },
  --  'github/copilot.vim',
  { 'nvim-neotest/nvim-nio', dir = require('lazy-nix-helper').get_plugin_path('nvim-nio') },
  {
    'nvim-tree/nvim-web-devicons',
    opts = {},
    dir = require('lazy-nix-helper').get_plugin_path('nvim-web-devicons'),
  },
  { 'echasnovski/mini.nvim', version = '*', dir = require('lazy-nix-helper').get_plugin_path('mini.icons') },
  { 'sindrets/diffview.nvim', dir = require('lazy-nix-helper').get_plugin_path('diffview.nvim') },
}
