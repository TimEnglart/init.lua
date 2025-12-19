return {
  {
    'https://codeberg.org/esensar/nvim-dev-container',
    dir = require('lazy-nix-helper').get_plugin_path('nvim-dev-container'),
    dependencies = 'nvim-treesitter/nvim-treesitter',
  },
}
