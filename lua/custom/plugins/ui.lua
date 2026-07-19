-- UI: notifications, command line, statusline, diagnostics list, focus modes
--
-- NOTE (vim.pack): plugins load in the order they are added, and each needs an
-- explicit `setup()` -- lazy.nvim's `dependencies` and `opts` do not exist here.

local gh = function(repo) return 'https://github.com/' .. repo end

-- nui.nvim and nvim-notify must both be present before noice is set up.
vim.pack.add {
  gh 'MunifTanjim/nui.nvim',
  gh 'rcarriga/nvim-notify',
  gh 'folke/noice.nvim',
}

vim.keymap.set('n', '<leader>na', '<cmd>Telescope notify<CR>', { desc = 'Show [a]ll [n]otifications' })
-- <CUSTOM CHANGE> not in custom_config: register the extension explicitly so <leader>na
-- works without relying on `:Telescope notify` autoloading it.
pcall(require('telescope').load_extension, 'notify')

-- require('notify').setup {
--   background_colour = '#000000',
--   enabled = false,
-- }

vim.keymap.set('n', '<leader>nn', '<cmd>Noice dismiss<CR>', { desc = 'Clear notifications' })

-- Function to clear the recording notification
local function clear_recording_notification() vim.cmd 'Noice dismiss' end

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

-- Diagnostics / quickfix list
vim.pack.add { gh 'folke/trouble.nvim' }
require('trouble').setup {}

vim.keymap.set('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<CR>', { desc = 'Open/close trouble list' })
vim.keymap.set('n', '<leader>xq', '<cmd>Trouble qflist toggle<CR>', { desc = 'Open trouble quickfix list' })
vim.keymap.set('n', '<leader>xL', '<cmd>Trouble loclist toggle<CR>', { desc = 'Open trouble location list' })
vim.keymap.set('n', '<leader>cl', '<cmd>Trouble lsp toggle focus=false win.position=right<cr>', { desc = 'LSP Definitions / references / ... (Trouble)' })
vim.keymap.set('n', '<leader>xb', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', { desc = 'Buffer Diagnostics (Trouble)' })
vim.keymap.set('n', '<leader>cs', '<cmd>Trouble symbols toggle focus=false<cr>', { desc = 'Symbols (Trouble)' })
vim.keymap.set('n', '<leader>xt', '<cmd>TodoTrouble<CR>', { desc = 'Open todos in trouble' })

-- Statusline. `nvim-web-devicons` is provided by MiniIcons.mock_nvim_web_devicons()
-- in init.lua, so the real plugin is not installed.
vim.pack.add { gh 'nvim-lualine/lualine.nvim' }
require('lualine').setup {
  sections = {
    -- lualine_b = { 'branch', 'diff', { 'diagnostics', symbols = { error = 'E', warn = 'W', info = 'I', hint = 'H' } } },
    -- lualine_c = { { 'filename', path = 3 } },
    lualine_c = { { 'buffers', show_filename_only = false } },
    lualine_x = { 'searchcount', 'encoding', 'filetype', 'filesize' },
  },
}

-- Transparency toggle
vim.pack.add { gh 'xiyaowong/nvim-transparent' }
vim.keymap.set('n', '<leader>tT', '<cmd>TransparentToggle<CR>', { desc = 'Toggle Transparent' })

-- Focus modes. twilight must be added before zen-mode (zen-mode integrates with it).
vim.pack.add {
  gh 'folke/twilight.nvim',
  gh 'folke/zen-mode.nvim',
}
vim.keymap.set('n', '<leader>tt', '<cmd>Twilight<CR>', { desc = 'Toggle twilight mode' })

require('zen-mode').setup {
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
}
vim.keymap.set('n', '<leader>tz', '<cmd>ZenMode<CR>', { desc = 'Toggle ZenMode' })
