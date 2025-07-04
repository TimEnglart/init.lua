return {
  'mfussenegger/nvim-dap',
  dir = require('lazy-nix-helper').get_plugin_path('nvim-dap'),
  dependencies = {
    -- Creates a beautiful debugger UI
    { 'rcarriga/nvim-dap-ui', dir = require('lazy-nix-helper').get_plugin_path('nvim-dap-ui') },

    -- Installs the debug adapters for you
    {
      'williamboman/mason.nvim',
      config = true,
      enabled = require('lazy-nix-helper').mason_enabled(),
      dir = require('lazy-nix-helper').get_plugin_path('mason.nvim'),
    },

    {
      'jay-babu/mason-nvim-dap.nvim',
      dir = require('lazy-nix-helper').get_plugin_path('mason-nvim-dap.nvim'),
      enabled = require('lazy-nix-helper').mason_enabled(),
    },
    {
      'Weissle/persistent-breakpoints.nvim',
      dir = require('lazy-nix-helper').get_plugin_path('persistent-breakpoints.nvim'),
    },

    -- Add your own debuggers here
    { 'leoluz/nvim-dap-go', dir = require('lazy-nix-helper').get_plugin_path('nvim-dap-go') },
  },
  config = function()
    local dap = require('dap')
    local dapui = require('dapui')

    if require('lazy-nix-helper').mason_enabled() then
      require('mason-nvim-dap').setup({
        -- Makes a best effort to setup the various debuggers with
        -- reasonable debug configurations
        automatic_setup = true,

        -- You can provide additional configuration to the handlers,
        -- see mason-nvim-dap README for more information
        handlers = {},

        -- You'll need to check that you have the required things installed
        -- online, please don't ask me how to install them :)
        ensure_installed = {
          -- Update this to ensure that you have the debuggers for the langs you want
          'delve',
        },
      })
    end

    require('persistent-breakpoints').setup({
      load_breakpoints_event = { 'BufReadPost' },
    })
    local p_breakpoints = require('persistent-breakpoints.api')

    -- Basic debugging keymaps, feel free to change to your liking!
    vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
    vim.keymap.set('n', '<F6>', dap.restart, { desc = 'Debug: Restart' })
    vim.keymap.set('n', '<F4>', dap.terminate, { desc = 'Debug: Terminate' })
    vim.keymap.set('n', '<F1>', dap.step_into, { desc = 'Debug: Step Into' })
    vim.keymap.set('n', '<F2>', dap.step_over, { desc = 'Debug: Step Over' })
    vim.keymap.set('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
    vim.keymap.set('n', '<leader>b', function()
      -- dap.toggle_breakpoint()
      p_breakpoints.toggle_breakpoint()
    end, { desc = 'Debug: Toggle Breakpoint' })

    vim.keymap.set('n', '<leader>B', function()
      local condition = vim.fn.input('Breakpoint condition: ')
      -- dap.set_breakpoint(condition)
      p_breakpoints.set_conditional_breakpoint(condition)
    end, { desc = 'Debug: Set Breakpoint' })

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup({
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    })

    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Install golang specific config
    local dap_go = require('dap-go')

    dap_go.setup({
      dap_configurations = {
        {
          type = 'go',
          name = 'Debug Package (with args)',
          request = 'launch',
          program = '${workspaceFolder}',
          args = dap_go.get_arguments,
        },
        {
          type = 'go',
          name = 'Debug Package (with config.out)',
          request = 'launch',
          program = '${workspaceFolder}',
          args = { '-config=${workspaceFolder}/.config.out' },
        },
      },
    })

    -- Zig dap
    -- configure codelldb adapter
    dap.adapters.codelldb = {
      type = 'server',
      port = '${port}',
      executable = {
        command = 'codelldb',
        args = { '--port', '${port}' },
      },
    }

    -- setup a debugger config for zig projects
    dap.configurations.zig = {
      {
        name = 'Launch',
        type = 'codelldb',
        request = 'launch',
        program = '${workspaceFolder}/zig-out/bin/${workspaceFolderBasename}',
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        args = {},
      },
    }

    dap.configurations.c = {
      {
        type = 'codelldb',
        request = 'launch',
        program = function()
          return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        --program = '${fileDirname}/${fileBasenameNoExtension}',
        cwd = '${workspaceFolder}',
        terminal = 'integrated',
        name = 'launch c',
      },
    }

    dap.configurations.cpp = dap.configurations.c
  end,
}
