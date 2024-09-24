-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  'christoomey/vim-tmux-navigator',
  {
    'nvim-treesitter/nvim-treesitter-context',
    config = function()
      require('treesitter-context').setup {
        multiline_threshold = 1, -- Maximum number of lines to show for a single context
      }
    end,
  },
  {
    'NeogitOrg/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim', -- required
      'sindrets/diffview.nvim', -- optional - Diff integration

      -- Only one of these is needed, not both.
      'nvim-telescope/telescope.nvim', -- optional
      -- 'ibhagwan/fzf-lua', -- optional
    },
    init = function()
      require('which-key').add {
        { '<leader>g', group = '[G]it' },
        { '<leader>gP', '<cmd>Neogit push<CR>', desc = 'git push' },
        { '<leader>gb', '<cmd>Telescope git_branches<CR>', desc = 'git branch with telescope' },
        { '<leader>gc', '<cmd>Neogit commit<CR>', desc = 'git commit' },
        { '<leader>gf', '<cmd>Neogit kind=floating<CR>', desc = 'git status in floating mode' },
        { '<leader>gl', '<cmd>Neogit log<CR>', desc = 'git log' },
        { '<leader>gp', '<cmd>Neogit pull<CR>', desc = 'git pull' },
        { '<leader>gs', '<cmd>Neogit<CR>', desc = 'git status' },
      }
    end,
    config = true,
  },
  {
    'numToStr/FTerm.nvim',
    config = function()
      local map = vim.api.nvim_set_keymap
      local opts = { noremap = true, silent = true }
      require('FTerm').setup {
        blend = 5,
        dimensions = {
          height = 0.90,
          width = 0.90,
          x = 0.5,
          y = 0.5,
        },
      }
      vim.keymap.set('n', '<A-t>', '<CMD>lua require("FTerm").toggle()<CR>')
      vim.keymap.set('t', '<A-t>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>')
    end,
  },
  {
    'rmagatti/goto-preview',
    config = function()
      require('goto-preview').setup {
        width = 120, -- Width of the floating window
        height = 15, -- Height of the floating window
        border = { '↖', '─', '┐', '│', '┘', '─', '└', '│' }, -- Border characters of the floating window
        default_mappings = true,
        debug = false, -- Print debug information
        opacity = nil, -- 0-100 opacity level of the floating window where 100 is fully transparent.
        resizing_mappings = false, -- Binds arrow keys to resizing the floating window.
        post_open_hook = nil, -- A function taking two arguments, a buffer and a window to be ran as a hook.
        references = { -- Configure the telescope UI for slowing the references cycling window.
          telescope = require('telescope.themes').get_dropdown { hide_preview = false },
        },
        -- These two configs can also be passed down to the goto-preview definition and implementation calls for one off "peak" functionality.
        focus_on_open = true, -- Focus the floating window when opening it.
        dismiss_on_move = false, -- Dismiss the floating window when moving the cursor.
        force_close = true, -- passed into vim.api.nvim_win_close's second argument. See :h nvim_win_close
        bufhidden = 'wipe', -- the bufhidden option to set on the floating window. See :h bufhidden
        stack_floating_preview_windows = true, -- Whether to nest floating windows
        preview_window_title = { enable = true, position = 'left' }, -- Whether
      }
    end,
  },
  {
    'rcarriga/nvim-notify',
    -- config = function()
    --   require('notify').setup {
    --     background_colour = '#000000',
    --     enabled = false,
    --   }
    -- end,
    keys = {
      { '<leader>na', '<cmd>Telescope notify<CR>', desc = 'Show [a]ll [n]otifications' },
    },
  },
  {
    'folke/noice.nvim',
    config = function()
      vim.keymap.set('n', '<leader>nn', '<cmd>Noice dismiss<CR>', { desc = 'Clear notifications' })

      -- Function to clear the recording notification
      local function clear_recording_notification()
        vim.cmd 'Noice dismiss'
      end

      -- Autocommand to clear notification when recording stops
      vim.api.nvim_create_autocmd('RecordingLeave', {
        pattern = '*',
        callback = clear_recording_notification,
      })

      require('noice').setup {
        presets = {
          lsp_doc_border = true, -- add a border to hover docs and signature help
        },
        -- add any options here
        routes = {
          {
            filter = {
              event = 'msg_show',
              any = {
                { find = '%d+L, %d+B' },
                { find = '; after #%d+' },
                { find = '; before #%d+' },
                { find = '%d fewer lines' },
                { find = '%d more lines' },
              },
            },
            opts = { skip = true },
          },
          {
            view = 'notify',
            filter = { event = 'msg_showmode' }, -- This will target macro recording notifications
            opts = {
              timeout = false, -- Make the notification persistent
            },
          },
        },
      }
    end,
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      'MunifTanjim/nui.nvim',
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      'rcarriga/nvim-notify',
    },
  },
  -- {
  --   'akinsho/bufferline.nvim',
  --   dependencies = { 'nvim-tree/nvim-web-devicons' },
  --   version = '*',
  --   opts = {
  --     options = {
  --       mode = 'tabs',
  --       separator_style = 'slant',
  --     },
  --   },
  -- },
  'tpope/vim-surround',
  {
    'folke/trouble.nvim',
    -- dependencies = 'nvim-tree/nvim-web-devicons',
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = 'Trouble',
    keys = {
      { '<leader>xx', '<cmd>Trouble diagnostics toggle<CR>', desc = 'Open/close trouble list' },
      { '<leader>xq', '<cmd>Trouble qflist toggle<CR>', desc = 'Open trouble quickfix list' },
      { '<leader>xL', '<cmd>Trouble loclist toggle<CR>', desc = 'Open trouble location list' },
      {
        '<leader>cl',
        '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
        desc = 'LSP Definitions / references / ... (Trouble)',
      },
      {
        '<leader>xb',
        '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
        desc = 'Buffer Diagnostics (Trouble)',
      },
      {
        '<leader>cs',
        '<cmd>Trouble symbols toggle focus=false<cr>',
        desc = 'Symbols (Trouble)',
      },

      { '<leader>xt', '<cmd>TodoTrouble<CR>', desc = 'Open todos in trouble' },
    },
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup {
        sections = {
          -- lualine_b = { 'branch', 'diff', { 'diagnostics', symbols = { error = 'E', warn = 'W', info = 'I', hint = 'H' } } },
          -- lualine_c = { { 'filename', path = 3 } },
          lualine_c = { { 'buffers', show_filename_only = false } },
          lualine_x = { 'searchcount', 'encoding', 'filetype', 'filesize' },
        },
      }
    end,
  },
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local harpoon = require 'harpoon'

      -- REQUIRED
      harpoon:setup {}
      -- REQUIRED

      vim.keymap.set('n', '<leader>a', function()
        harpoon:list():add()
      end, { desc = '[A]dd buffer to harpoon list' })
      vim.keymap.set('n', '<A-h>', function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end)

      -- vim.keymap.set('n', '<C-h>', function()
      --   harpoon:list():select(1)
      -- end)
      -- vim.keymap.set('n', '<C-t>', function()
      --   harpoon:list():select(2)
      -- end)
      -- vim.keymap.set('n', '<C-n>', function()
      --   harpoon:list():select(3)
      -- end)
      -- vim.keymap.set('n', '<C-s>', function()
      --   harpoon:list():select(4)
      -- end)

      -- Toggle previous & next buffers stored within Harpoon list
      vim.keymap.set('n', '<A-p>', function()
        harpoon:list():prev()
      end)
      vim.keymap.set('n', '<A-n>', function()
        harpoon:list():next()
      end)

      -- basic telescope configuration
      local conf = require('telescope.config').values
      local function toggle_telescope(harpoon_files)
        local file_paths = {}
        for _, item in ipairs(harpoon_files.items) do
          table.insert(file_paths, item.value)
        end

        require('telescope.pickers')
          .new({}, {
            prompt_title = 'Harpoon',
            finder = require('telescope.finders').new_table {
              results = file_paths,
            },
            previewer = conf.file_previewer {},
            sorter = conf.generic_sorter {},
          })
          :find()
      end

      vim.keymap.set('n', '<leader>sp', function()
        toggle_telescope(harpoon:list())
      end, { desc = '[S]earch in har[p]oon' })
    end,
  },
  {
    'xiyaowong/nvim-transparent',
    keys = {
      { '<leader>tT', '<cmd>TransparentToggle<CR>', desc = 'Toggle Transparent' },
    },
  },
  {
    'folke/twilight.nvim',
    keys = {
      { '<leader>tt', '<cmd>Twilight<CR>', desc = 'Toggle twilight mode' },
    },
  },
  {
    'folke/zen-mode.nvim',
    dependencies = { 'folke/twilight.nvim' },
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      plugins = {
        -- disable some global vim options (vim.o...)
        options = {
          enabled = true,
          ruler = true, -- disables the ruler text in the cmd line area
          showcmd = false, -- disables the command in the last line of the screen
          -- you may turn on/off statusline in zen mode by setting 'laststatus'
          -- statusline will be shown only if 'laststatus' == 3
          laststatus = 3, -- turn off the statusline in zen mode
        },
        twilight = { enabled = false }, -- enable to start Twilight when zen mode opens
        gitsigns = { enabled = false }, -- disables git signs
        tmux = { enabled = true }, -- disables the tmux statusline
      },
    },
    keys = {
      { '<leader>tz', '<cmd>ZenMode<CR>', desc = 'Toggle ZenMode' },
    },
  },

  -- Database
  {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = {
      { 'tpope/vim-dotenv', lazy = true },
      { 'tpope/vim-dadbod', lazy = true },
      { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
    },
    cmd = {
      'DBUI',
      'DBUIToggle',
      'DBUIAddConnection',
      'DBUIFindBuffer',
    },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_winwidth = 45
      vim.g.db_ui_show_help = 0 -- for help just type '?'
      vim.g.db_ui_use_nvim_notify = 1
      vim.g.db_ui_win_position = 'left'
      vim.g.db_ui_auto_execute_table_helpers = 1

      require('which-key').add {
        { '<leader>D', group = '󰆼 Db Tools' },
        { '<leader>Df', '<cmd>DBUIFindBuffer<cr>', desc = ' DB UI Find buffer' },
        { '<leader>Dl', '<cmd>DBUILastQueryInfo<cr>', desc = ' DB UI Last query infos' },
        { '<leader>Dr', '<cmd>DBUIRenameBuffer<cr>', desc = ' DB UI Rename buffer' },
        { '<leader>Du', '<cmd>DBUIToggle<cr>', desc = ' DB UI Toggle' },
      }
    end,
  },
  'kristijanhusak/vim-dadbod-completion',
  {
    'tpope/vim-dadbod',
    opt = true,
    requires = {
      'kristijanhusak/vim-dadbod-ui',
      'kristijanhusak/vim-dadbod-completion',
    },
    config = function()
      -- require('config.dadbod').setup()
    end,
    -- [[ info ]]
    -- For postgres you need psql :
    --    sudo nala install -y postgresql-client postgresql-client-common
    --
  },

  -- Debugger
  'nvim-neotest/nvim-nio',
  {
    'mfussenegger/nvim-dap',
    keys = {
      { '<leader>db', '<cmd>DapToggleBreakpoint<CR>', desc = 'Toggle debug breakpoint' },
      { '<leader>dC', "<cmd>lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition : '))<CR>", desc = 'Set Conditional breakpoint' },
      { '<leader>dc', '<cmd>DapContinue<CR>', desc = 'Dap continue' },
      { '<leader>di', '<cmd>DapStepInto<CR>', desc = 'Dap step into' },
      { '<leader>do', '<cmd>DapStepOut<CR>', desc = 'Dap step out' },
      { '<leader>dn', '<cmd>DapStepOver<CR>', desc = 'Dap step over' },
      { '<leader>dk', '<cmd>DapTerminate<CR>', desc = 'Dap kill/terminate' },
    },
    init = function()
      vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl = 'DapBreakpoint', linehl = 'DapBreakpoint', numhl = 'DapBreakpoint' })
      vim.fn.sign_define('DapBreakpointCondition', { text = 'ﳁ', texthl = 'DapBreakpoint', linehl = 'DapBreakpoint', numhl = 'DapBreakpoint' })
    end,
  },
  {
    'rcarriga/nvim-dap-ui',
    dependencies = {
      'mfussenegger/nvim-dap',
      'nvim-neotest/nvim-nio',
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'
      dapui.setup()
      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated['dapui_config'] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited['dapui_config'] = function()
        dapui.close()
      end
      vim.keymap.set('n', '<leader>dt', "<cmd>lua require('dapui').toggle()<CR>", { desc = 'DapUI Toggle' })
      vim.keymap.set('n', '<leader>dr', "<cmd>lua require('dapui').open({reset = true})<CR>", { desc = 'Reset DapUI' })
      vim.keymap.set(
        'n',
        '<leader>df',
        "<cmd>lua require('dapui').float_element(_, {height=40, width=50, position='center'})<CR>",
        { desc = 'Open element in a floating window' }
      )
      vim.keymap.set('n', '<leader>ht', "<cmd>lua require('harpoon.ui').toggle_quick_menu()<CR>", { desc = 'Toggle DapUI in Harpoon' })
    end,
    -- keys = {
    --   { '<leader>dt', ':DapUiToggle<CR>', desc = 'DapUI Toggle' },
    --   { '<leader>dr', ":lua require('dapui').open({reset = true})<CR>", desc = 'Reset DapUI' },
    --   { '<leader>ht', ":lua require('harpoon.ui').toggle_quick_menu()<CR>", desc = 'Toggle DapUI in Harpoon' },
    -- },
  },
  {
    'theHamsta/nvim-dap-virtual-text',
    config = function()
      require('nvim-dap-virtual-text').setup()
    end,
  },
  {
    'mfussenegger/nvim-dap-python',
    ft = 'python',
    dependencies = {
      'mfussenegger/nvim-dap',
      'rcarriga/nvim-dap-ui',
      'nvim-neotest/nvim-nio',
    },
    config = function(_, opts)
      local path = '~/.local/share/nvim/mason/packages/debugpy/venv/bin/python'
      require('dap-python').setup(path)
      vim.keymap.set('n', '<leader>dpm', "<cmd>lua require('dap-python').test_method()<CR>", { desc = 'Debug python method' })
      vim.keymap.set('n', '<leader>dpc', "<cmd>lua require('dap-python').test_class()<CR>", { desc = 'Debug python class' })
    end,
  },
  {
    'tpope/vim-fugitive',
    keys = {
      { '<leader>gd', '<CMD>Gvdiffsplit!<CR>', desc = 'Gvdiffsplit' },
    },
  },
  {
    'ThePrimeagen/git-worktree.nvim',
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require('git-worktree').setup()
      require('telescope').load_extension 'git_worktree'

      local Job = require 'plenary.job'

      -- Define the custom function
      local function create_git_worktree_and_configure()
        -- Call the create_git_worktree function from the telescope extension
        require('telescope').extensions.git_worktree.create_git_worktree()

        -- Function to check and configure remote.origin.fetch
        local function check_and_configure_fetch()
          -- Check the current value of remote.origin.fetch
          Job:new({
            command = 'git',
            args = { 'config', '--get', 'remote.origin.fetch' },
            on_exit = function(j, return_val)
              local output = table.concat(j:result(), '\n')
              if output ~= '+refs/heads/*:refs/remotes/origin/*' then
                -- Configure remote.origin.fetch if it's not set correctly
                Job:new({
                  command = 'git',
                  args = { 'config', 'remote.origin.fetch', '+refs/heads/*:refs/remotes/origin/*' },
                  on_exit = function(j, return_val)
                    if return_val == 0 then
                      print 'Successfully configured remote.origin.fetch'
                    else
                      print 'Failed to configure remote.origin.fetch'
                    end
                  end,
                }):start()
              else
                print 'remote.origin.fetch is already configured correctly'
              end
            end,
          }):start()
        end

        -- Call the function to check and configure fetch
        check_and_configure_fetch()
      end

      -- Set the keymap
      vim.keymap.set('n', '<Leader>gW', create_git_worktree_and_configure, { desc = 'Create a new worktree and configure fetch' })
      vim.keymap.set('n', '<Leader>gw', "<CMD>lua require('telescope').extensions.git_worktree.git_worktrees()<CR>", { desc = 'Show git worktrees' })
    end,
  },
  {
    'mg979/vim-visual-multi',
    branch = 'master',
    -- config = function()
    --   vim.g.VM_leader = '\t'
    -- end,
  },
  -- f-strings
  -- - auto-convert strings to f-strings when typing `{}` in a string
  -- - also auto-converts f-strings back to regular strings when removing `{}`
  -- {
  --   'chrisgrieser/nvim-puppeteer',
  --   dependencies = 'nvim-treesitter/nvim-treesitter',
  -- },
  -- Docstring creation
  -- - quickly create docstrings via `<leader>a`
  {
    'danymat/neogen',
    opts = true,
    keys = {
      {
        '<leader>dg',
        function()
          require('neogen').generate()
        end,
        desc = 'Generate Docstring',
      },
    },
  },
  {
    'linux-cultist/venv-selector.nvim',
    dependencies = {
      'neovim/nvim-lspconfig',
      'mfussenegger/nvim-dap',
      'mfussenegger/nvim-dap-python', --optional
      'nvim-telescope/telescope.nvim',
    },
    lazy = false,
    branch = 'regexp', -- This is the regexp branch, use this for the new version
    config = function()
      require('venv-selector').setup {
        settings = {
          search = {
            anaconda_base = {
              command = 'fd /python$ $HOME/miniforge3/bin --full-path --color never -E /proc',
              type = 'anaconda',
            },
            anaconda_envs = {
              command = 'fd /bin/python$ $HOME/miniforge3/envs --full-path --color never -E /proc -E pkgs',
              type = 'anaconda',
            },
          },
        },
      }
    end,
    keys = {
      { '<leader>v', '<cmd>VenvSelect<cr>' },
    },
  },
  -- {
  --   'someone-stole-my-name/yaml-companion.nvim',
  --   dependencies = {
  --     { 'neovim/nvim-lspconfig' },
  --     { 'nvim-lua/plenary.nvim' },
  --     { 'nvim-telescope/telescope.nvim' },
  --   },
  --   config = function()
  --     require('telescope').load_extension 'yaml_schema'
  --     vim.keymap.set('n', '<leader>y', '<cmd>Telescope yaml_schema<CR>', { desc = 'Select a yaml schema' })
  --   end,
  -- },
  {
    'kevinhwang91/nvim-ufo',
    dependencies = {
      'kevinhwang91/promise-async',
      config = function()
        vim.opt.foldcolumn = '1' -- '0' is not bad
        vim.opt.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
        vim.opt.foldlevelstart = 99
        vim.opt.foldenable = true

        -- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
        vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
        vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
        vim.keymap.set('n', 'zK', function()
          local winid = require('ufo').peekFoldedLinesUnderCursor()
          if not winid then
            vim.lsp.buf.hover()
          end
        end, { desc = 'Peek fold' })

        require('ufo').setup {
          provider_selector = function(bufnr, filetype, buftype)
            return { 'lsp', 'indent' }
          end,
        }
      end,
    },
  },
  {
    'amitds1997/remote-nvim.nvim',
    version = 'v0.3.9', -- Pin to GitHub releases
    dependencies = {
      'nvim-lua/plenary.nvim', -- For standard functions
      'MunifTanjim/nui.nvim', -- To build the plugin UI
      'nvim-telescope/telescope.nvim', -- For picking b/w different remote methods
    },
    config = function()
      vim.keymap.set('n', '<leader>rs', '<CMD>RemoteStart<CR>', { desc = 'Start a remote Neovim' })
      vim.keymap.set('n', '<leader>rS', '<CMD>RemoteStop<CR>', { desc = 'Stop a remote Neovim' })
      vim.keymap.set('n', '<leader>ri', '<CMD>RemoteInfo<CR>', { desc = 'Remote Neovim Info' })
      vim.keymap.set('n', '<leader>rl', '<CMD>RemoteLog<CR>', { desc = 'Remote Neovim Logs' })

      -- Function to prompt for an argument and execute :RemoteCleanup with that argument
      local function remote_cleanup()
        -- Prompt the user for input
        local input = vim.fn.input 'Enter the remote name: '

        -- Check if input is not empty
        if input and input ~= '' then
          -- Execute the :RemoteCleanup command with the provided argument
          vim.cmd('RemoteCleanup ' .. input)
        else
          print 'Remote name is required.'
        end
      end
      vim.keymap.set('n', '<leader>rc', remote_cleanup, { desc = 'Cleanup a remote Neovim' })

      require('remote-nvim').setup {
        client_callback = function(port, workspace_config)
          local session_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
          local window_name = ('Remote: %s'):format(workspace_config.host)
          local cmd = ("tmux new-window -n '%s' 'nvim --server localhost:%s --remote-ui'"):format(window_name, port)
          vim.fn.jobstart(cmd, {
            detach = true,
            on_exit = function(job_id, exit_code, event_type)
              -- This function will be called when the job exits
              print('Client', job_id, 'exited with code', exit_code, 'Event type:', event_type)
            end,
          })
        end,
      }
    end,
  },
  {
    'Vigemus/iron.nvim',
    -- keys = {
    --   { '<leader>i', '<cmd>IronRepl<cr>', desc = '󱠤 Toggle REPL' },
    --   { '<leader>I', '<cmd>IronRestart<cr>', desc = '󱠤 Restart REPL' },
    --
    --   -- these keymaps need no right-hand-side, since that is defined by the
    --   -- plugin config further below
    --   { '+', mode = { 'n', 'x' }, desc = '󱠤 Send-to-REPL Operator' },
    --   { '++', desc = '󱠤 Send Line to REPL' },
    -- },
    config = function()
      local iron = require 'iron.core'
      local view = require 'iron.view'

      iron.setup {
        config = {
          -- Whether a repl should be discarded or not
          scratch_repl = true,
          -- Your repl definitions come here
          repl_definition = {
            -- sh = {
            --   -- Can be a table or a function that
            --   -- returns a table (see below)
            --   command = { 'zsh' },
            -- },
            python = {
              command = { 'ipython', '-i', '--no-autoindent', '--nosep' },
              format = require('iron.fts.common').bracketed_paste_python,
            },
          },
          -- -- `view.center` takes either one or two arguments
          -- repl_open_cmd = view.center '80%',
          repl_open_cmd = 'vertical botright 85 split',
        },
        -- Iron doesn't set keymaps by default anymore.
        -- You can set them here or manually add keymaps to the functions in iron.core
        keymaps = {
          send_line = '<leader>ia',
          visual_send = '<leader>ia',
          send_motion = '+',
          send_file = '<leader>iF',
          send_paragraph = '<leader>ip',
          -- send_until_cursor = '<space>su',
          -- send_mark = '<space>sm',
          -- mark_motion = '<space>mc',
          -- mark_visual = '<space>mc',
          -- remove_mark = '<space>md',
          -- cr = '<space>s<cr>',
          interrupt = '<leader>ii',
          exit = '<leader>ik',
          -- clear = '<leader>ic',
        },
        -- If the highlight is on, you can change how it looks
        -- For the available options, check nvim_set_hl
        highlight = {
          italic = true,
        },
        ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
      }
      -- iron also has a list of commands, see :h iron-commands for all available commands
      vim.keymap.set('n', '<leader>it', '<cmd>IronRepl<cr>', { desc = 'Start REPL' })
      vim.keymap.set('n', '<leader>ir', '<cmd>IronRestart<cr>', { desc = 'Restart REPL' })
      vim.keymap.set('n', '<leader>if', '<cmd>IronFocus<cr>', { desc = 'Focus REPL' })
      -- vim.keymap.set('n', '<space>rh', '<cmd>IronHide<cr>')

      -- Global function to send 'pinfo' command for the entire line to IPython REPL
      function _G.send_ipython_help()
        -- Get the entire line under the cursor
        local line = vim.fn.getline '.'
        -- Create the pinfo command without adding an extra newline
        local pinfo_command = line .. '?'
        -- Send the command to the REPL
        iron.send(nil, { pinfo_command })
        -- Manually send a newline to execute the command
        iron.send(nil, { '' })
        -- Focus on the REPL
        vim.cmd 'IronFocus'
      end

      vim.keymap.set('n', '<leader>ih', '<CMD>lua send_ipython_help()<CR>', { desc = 'Send line for documentation' })
    end,
  },
  -- {
  --   'iamcco/markdown-preview.nvim',
  --   cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
  --   ft = { 'markdown' },
  --   build = function()
  --     vim.fn['mkdp#util#install']()
  --   end,
  --   -- keys = {
  --   --   { '<leader>tm', '<CMD>MarkdownPreviewToggle<CR>', desc = 'Toggle markdown preview' },
  --   -- },
  -- },
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    build = 'cd app && npm install',
    init = function()
      vim.g.mkdp_filetypes = { 'markdown' }
    end,
    ft = { 'markdown' },
    keys = {
      { '<leader>tm', '<CMD>MarkdownPreviewToggle<CR>', desc = 'Toggle markdown preview' },
    },
  },
  {
    'christoomey/vim-tmux-runner',
    enabled = true and os.getenv 'TMUX' ~= nil,
    event = 'VeryLazy',
    keys = {
      { '<leader>tC', '<cmd>VtrClearRunner<cr>', desc = 'Clear Tmux Runner' },
      { '<leader>tF', '<cmd>VtrFocusRunner<cr>', desc = 'Focus Tmux Runner' },
      { '<leader>tR', '<cmd>VtrReorientRunner<cr>', desc = 'Reorient Tmux Runner' },
      { '<leader>ta', '<cmd>VtrReattachRunner<cr>', desc = 'Reattach Tmux Runner' },
      { '<leader>tc', '<cmd>VtrFlushCommand<cr>', desc = 'Flush Tmux Runner Command' },
      { '<leader>tf', '<cmd>VtrSendFile<cr>', desc = 'Send File to Tmux Runner' },
      { '<leader>tk', '<cmd>VtrKillRunner<cr>', desc = 'Kill Tmux Runner' },
      { '<leader>tl', '<cmd>VtrSendLinesToRunner<cr>', desc = 'Send Lines to Tmux Runner' },
      { '<leader>to', "<cmd>VtrOpenRunner {'orientation': 'h', 'percentage': 50}<cr>", desc = 'Open Tmux Runner' },
      { '<leader>tr', '<cmd>VtrResizeRunner<cr>', desc = 'Resize Tmux Runner' },
      { '<leader>ts', '<cmd>VtrSendCommandToRunner<cr>', desc = 'Send Command to Tmux Runner' },
    },
    config = function()
      vim.g.VtrStripLeadingWhitespace = 0
      vim.g.VtrClearEmptyLines = 0
      vim.g.VtrAppendNewline = 1
    end,
  },
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    ---@type Flash.Config
    opts = {},
  -- stylua: ignore
  keys = {
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  },
  },
  {
    'LunarVim/bigfile.nvim',
    event = 'BufReadPre',
    opts = {
      filesize = 2, -- size of the file in MiB, the plugin round file sizes to the closest MiB
    },
    config = function(_, opts)
      require('bigfile').setup(opts)
    end,
  },
}
