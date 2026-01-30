return {
  {
    'https://codeberg.org/esensar/nvim-dev-container',
    dir = require('lazy-nix-helper').get_plugin_path('nvim-dev-container'),
    opts = {},
  },
  {
    'https://github.com/jamestthompson3/nvim-remote-containers',
    dir = require('lazy-nix-helper').get_plugin_path('nvim-remote-containers'),
    config = function() end,
  },
}
