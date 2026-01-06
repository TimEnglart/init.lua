return {
  -- Highlight, edit, and navigate code
  {
    'nvim-treesitter/nvim-treesitter',
    dir = require('lazy-nix-helper').get_plugin_path('nvim-treesitter'),
    dependencies = {
      {
        'nvim-treesitter/nvim-treesitter-textobjects',
        dir = require('lazy-nix-helper').get_plugin_path('nvim-treesitter-textobjects'),
        init = function()
          -- Disable entire built-in ftplugin mappings to avoid conflicts.
          -- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
          vim.g.no_plugin_maps = true

          -- Or, disable per filetype (add as you like)
          -- vim.g.no_python_maps = true
          -- vim.g.no_ruby_maps = true
          -- vim.g.no_rust_maps = true
          -- vim.g.no_go_maps = true
        end,
        config = function()
          -- https://github.com/nvim-treesitter/nvim-treesitter-textobjects/tree/main
          require('nvim-treesitter-textobjects').setup {
            select = {
              -- Automatically jump forward to textobj, similar to targets.vim
              lookahead = true,
              -- You can choose the select mode (default is charwise 'v')
              --
              -- Can also be a function which gets passed a table with the keys
              -- * query_string: eg '@function.inner'
              -- * method: eg 'v' or 'o'
              -- and should return the mode ('v', 'V', or '<c-v>') or a table
              -- mapping query_strings to modes.
              selection_modes = {
                ['@parameter.outer'] = 'v', -- charwise
                ['@function.outer'] = 'V', -- linewise
                -- ['@class.outer'] = '<c-v>', -- blockwise
              },
              -- If you set this to `true` (default is `false`) then any textobject is
              -- extended to include preceding or succeeding whitespace. Succeeding
              -- whitespace has priority in order to act similarly to eg the built-in
              -- `ap`.
              --
              -- Can also be a function which gets passed a table with the keys
              -- * query_string: eg '@function.inner'
              -- * selection_mode: eg 'v'
              -- and should return true of false
              include_surrounding_whitespace = false,
            },
            move = {
              -- whether to set jumps in the jumplist
              set_jumps = true,
            },
          }

          -- Select Keymappings
          vim.keymap.set({ 'x', 'o' }, 'am', function()
            require 'nvim-treesitter-textobjects.select'.select_textobject('@function.outer', 'textobjects')
          end)
          vim.keymap.set({ 'x', 'o' }, 'im', function()
            require 'nvim-treesitter-textobjects.select'.select_textobject('@function.inner', 'textobjects')
          end)
          vim.keymap.set({ 'x', 'o' }, 'ac', function()
            require 'nvim-treesitter-textobjects.select'.select_textobject('@class.outer', 'textobjects')
          end)
          vim.keymap.set({ 'x', 'o' }, 'ic', function()
            require 'nvim-treesitter-textobjects.select'.select_textobject('@class.inner', 'textobjects')
          end)
          -- You can also use captures from other query groups like `locals.scm`
          vim.keymap.set({ 'x', 'o' }, 'as', function()
            require 'nvim-treesitter-textobjects.select'.select_textobject('@local.scope', 'locals')
          end)

          -- Swap Keymappings
          vim.keymap.set('n', '<leader>a', function()
            require('nvim-treesitter-textobjects.swap').swap_next '@parameter.inner'
          end)
          vim.keymap.set('n', '<leader>A', function()
            require('nvim-treesitter-textobjects.swap').swap_previous '@parameter.outer'
          end)

          -- Move Keymappings
          vim.keymap.set({ 'n', 'x', 'o' }, ']m', function()
            require('nvim-treesitter-textobjects.move').goto_next_start('@function.outer', 'textobjects')
          end)
          vim.keymap.set({ 'n', 'x', 'o' }, ']]', function()
            require('nvim-treesitter-textobjects.move').goto_next_start('@class.outer', 'textobjects')
          end)
          -- You can also pass a list to group multiple queries.
          vim.keymap.set({ 'n', 'x', 'o' }, ']o', function()
            require('nvim-treesitter-textobjects.move').goto_next_start({ '@loop.inner', '@loop.outer' }, 'textobjects')
          end)
          -- You can also use captures from other query groups like `locals.scm` or `folds.scm`
          vim.keymap.set({ 'n', 'x', 'o' }, ']s', function()
            require('nvim-treesitter-textobjects.move').goto_next_start('@local.scope', 'locals')
          end)
          vim.keymap.set({ 'n', 'x', 'o' }, ']z', function()
            require('nvim-treesitter-textobjects.move').goto_next_start('@fold', 'folds')
          end)

          vim.keymap.set({ 'n', 'x', 'o' }, ']M', function()
            require('nvim-treesitter-textobjects.move').goto_next_end('@function.outer', 'textobjects')
          end)
          vim.keymap.set({ 'n', 'x', 'o' }, '][', function()
            require('nvim-treesitter-textobjects.move').goto_next_end('@class.outer', 'textobjects')
          end)

          vim.keymap.set({ 'n', 'x', 'o' }, '[m', function()
            require('nvim-treesitter-textobjects.move').goto_previous_start('@function.outer', 'textobjects')
          end)
          vim.keymap.set({ 'n', 'x', 'o' }, '[[', function()
            require('nvim-treesitter-textobjects.move').goto_previous_start('@class.outer', 'textobjects')
          end)

          vim.keymap.set({ 'n', 'x', 'o' }, '[M', function()
            require('nvim-treesitter-textobjects.move').goto_previous_end('@function.outer', 'textobjects')
          end)
          vim.keymap.set({ 'n', 'x', 'o' }, '[]', function()
            require('nvim-treesitter-textobjects.move').goto_previous_end('@class.outer', 'textobjects')
          end)

          -- Go to either the start or the end, whichever is closer.
          -- Use if you want more granular movements
          vim.keymap.set({ 'n', 'x', 'o' }, ']d', function()
            require('nvim-treesitter-textobjects.move').goto_next('@conditional.outer', 'textobjects')
          end)
          vim.keymap.set({ 'n', 'x', 'o' }, '[d', function()
            require('nvim-treesitter-textobjects.move').goto_previous('@conditional.outer', 'textobjects')
          end)

          -- Repeat movements
          local ts_repeat_move = require 'nvim-treesitter-textobjects.repeatable_move'
          vim.keymap.set({ 'n', 'x', 'o' }, ';', ts_repeat_move.repeat_last_move)
          vim.keymap.set({ 'n', 'x', 'o' }, ',', ts_repeat_move.repeat_last_move_opposite)
        end,
      },
      {
        'nvim-treesitter/nvim-treesitter-context',
        dir = require('lazy-nix-helper').get_plugin_path('nvim-treesitter-context'),
      },
    },
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').setup()

      -- Handle parser installation
      local auto_install = require('lazy-nix-helper').mason_enabled()
      local ensure_installed =
        { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim' }

      local installed = require('nvim-treesitter.config').get_installed()
      local not_installed = vim.tbl_filter(function(parser)
        return not vim.tbl_contains(installed, parser)
      end, ensure_installed)
      if #not_installed > 0 and auto_install then
        require('nvim-treesitter').install(not_installed)
      end
    end,
  },
}
