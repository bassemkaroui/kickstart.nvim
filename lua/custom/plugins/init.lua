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
      require('which-key').register {
        ['<leader>n'] = {
          name = 'Neogit and notifications',
          s = { '<cmd>Neogit<CR>', 'git status' },
          f = { '<cmd>Neogit kind=floating<CR>', 'git status in floating mode' },
          c = { '<cmd>Neogit commit<CR>', 'git commit' },
          p = { '<cmd>Neogit pull<CR>', 'git pull' },
          P = { '<cmd>Neogit push<CR>', 'git push' },
          b = { '<cmd>Telescope git_branches<CR>', 'git branch with telescope' },
          l = { '<cmd>Neogit log<CR>', 'git log' },
        },
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
      { '<leader>sN', '<cmd>Telescope notify<CR>', desc = '[S]earch [N]otifications' },
    },
  },
  {
    'folke/noice.nvim',
    config = function()
      vim.keymap.set('n', '<leader>nn', '<cmd>Noice dismiss<CR>', { desc = 'Clear notifications' })

      require('noice').setup {
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
  {
    'akinsho/bufferline.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    version = '*',
    opts = {
      options = {
        mode = 'tabs',
        separator_style = 'slant',
      },
    },
  },
  'tpope/vim-surround',
  {
    'folke/trouble.nvim',
    dependencies = 'nvim-tree/nvim-web-devicons',
    keys = {
      { '<leader>xx', '<cmd>TroubleToggle<CR>', desc = 'Open/close trouble list' },
      { '<leader>xw', '<cmd>TroubleToggle workspace_diagnostics<CR>', desc = 'Open trouble workspace diagnostics' },
      { '<leader>xd', '<cmd>TroubleToggle document_diagnostics<CR>', desc = 'Open trouble document diagnostics' },
      { '<leader>xq', '<cmd>TroubleToggle quickfix<CR>', desc = 'Open trouble quickfix list' },
      { '<leader>xl', '<cmd>TroubleToggle loclist<CR>', desc = 'Open trouble location list' },
      { '<leader>xt', '<cmd>TodoTrouble<CR>', desc = 'Open todos in trouble' },
    },
  },
  -- {
  --   'nvim-lualine/lualine.nvim',
  --   dependencies = { 'nvim-tree/nvim-web-devicons' },
  --   config = function()
  --     require('lualine').setup {
  --       sections = {
  --         lualine_c = { { 'filename', path = 3 } },
  --         lualine_x = { 'encoding', 'filetype' },
  --         lualine_z = {'searchcount', 'location'}
  --       },
  --     }
  --   end,
  -- },
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

      require('which-key').register {
        ['<leader>D'] = {
          name = '󰆼 Db Tools',
          u = { '<cmd>DBUIToggle<cr>', ' DB UI Toggle' },
          f = { '<cmd>DBUIFindBuffer<cr>', ' DB UI Find buffer' },
          r = { '<cmd>DBUIRenameBuffer<cr>', ' DB UI Rename buffer' },
          l = { '<cmd>DBUILastQueryInfo<cr>', ' DB UI Last query infos' },
        },
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
}
