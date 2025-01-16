return function (lazy_nix_helper_path, plugins, gitPath)
-- Check to see if we are on a Nix System, bootstrap lazy_nix_helper in the same way lazy is bootstrapped
if not lazy_nix_helper_path or not vim.loop.fs_stat(lazy_nix_helper_path) then
  lazy_nix_helper_path = vim.fn.stdpath("data") .. "/lazy-nix-helper/lazy-nix-helper.nvim"
  if not vim.loop.fs_stat(lazy_nix_helper_path) then
    vim.fn.system({
      gitPath,
      "clone",
      "--filter=blob:none",
      "https://github.com/b-src/lazy-nix-helper.nvim.git",
      lazy_nix_helper_path,
    })
  end
end

-- add the Lazy-Nix-Helper plugin to the vim runtime
vim.opt.rtp:prepend(lazy_nix_helper_path)

-- call the Lazy-Nix-Helper setup function. pass a default lazypath for non-nix systems as an argument
local non_nix_lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
require("lazy-nix-helper").setup({ lazypath = non_nix_lazypath, input_plugin_table = plugins })

local lazypath = require("lazy-nix-helper").lazypath()
-- local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    gitPath,
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local is_nix = require("lazy-nix-helper.util").in_a_nix_environment()
require("lazy").setup({
    performance = { reset_packpath = not is_nix, rtp = { reset = not is_nix } },
    spec = { { import = "plugins" }, },
    change_detection = { notify = not is_nix },
})
end
