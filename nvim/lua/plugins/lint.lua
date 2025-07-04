return {
  'mfussenegger/nvim-lint',
  dir = require('lazy-nix-helper').get_plugin_path('nvim-lint'),
  lazy = true,
  event = { 'BufReadPre', 'BufNewFile' }, -- to disable, comment this out
  config = function()
    local lint = require('lint')

    -- Our staging list of linters
    local lintersForFt = {
      -- javascript = { "eslint_d" },
      -- typescript = { "eslint_d" },
      -- vue = { "eslint_d" },
      go = { 'golangcilint' },
      yaml = { 'yq' },
      nix = { 'nix' },
      -- python = { "ruff" },
    }

    -- Define the table for available linters
    lint.linters_by_ft = {}

    for ft, linterList in ipairs(lintersForFt) do
      for _, linter in ipairs(linterList) do
        if vim.fn.executable(lint.linters[linter].cmd()) == 1 then
          table.insert(lintersForFt[ft], linter)
        end
      end
    end

    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })

    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function()
        lint.try_lint()
      end,
    })

    vim.keymap.set('n', '<leader>li', function()
      lint.try_lint()
    end, { desc = 'Trigger linting for current file' })
  end,
}
