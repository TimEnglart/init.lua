require('mappings')
require('options')

-- plugins, lazy_nix_helper_path, and gitPath are defined in nix/mkNeovim.nix before this file is sourced
require('lazy_setup')((lazy_nix_helper_path or nil), (plugins or {}), (gitPath or 'git'))

local augroup = vim.api.nvim_create_augroup
local ThePrimeagenGroup = augroup('ThePrimeagen', {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup('HighlightYank', {})

-- function R(name)
--  require('plenary.reload').reload_module(name)
-- end

autocmd('TextYankPost', {
  group = yank_group,
  pattern = '*',
  callback = function()
    vim.highlight.on_yank({
      higroup = 'IncSearch',
      timeout = 40,
    })
  end,
})

autocmd({ 'BufWritePre' }, {
  group = ThePrimeagenGroup,
  pattern = '*',
  command = [[%s/\s\+$//e]],
})

autocmd({ 'InsertLeave', 'TextChanged', 'TextChangedP' }, {
  pattern = '*',
  callback = function()
    if vim.bo.modifiable and not vim.bo.readonly then
      vim.cmd('silent! update')
    end
  end,
})

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
