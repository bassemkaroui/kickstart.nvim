-- Database tooling, remote development, markdown preview, Claude Code, OpenFGA
--
-- NOTE (vim.pack): plugins load in the order they are added, and each needs an
-- explicit `setup()` -- lazy.nvim's `dependencies` and `opts` do not exist here.
-- Build steps live in the `PackChanged` autocmd in init.lua SECTION 3.
-- This module must load AFTER `custom.plugins.editor` (claudecode uses snacks).

local gh = function(repo) return 'https://github.com/' .. repo end

local function with_doppler(fn)
  return function()
    require('custom.doppler').load_env { force = true, sync = true }
    fn()
  end
end

-- Database. dadbod and vim-dotenv must precede dadbod-ui; dadbod-completion
-- provides the `vim_dadbod_completion.blink` module referenced by blink.cmp's
-- `sources.per_filetype.sql` in init.lua.
--
-- <CUSTOM CHANGE> these vim.g settings were lazy.nvim's `init`: vim-dadbod-ui reads
-- them when it is sourced, so they must be set before the plugin loads.
vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_winwidth = 45
vim.g.db_ui_show_help = 0 -- for help just type '?'
vim.g.db_ui_use_nvim_notify = 1
vim.g.db_ui_win_position = 'left'
vim.g.db_ui_auto_execute_table_helpers = 1

vim.pack.add {
  gh 'tpope/vim-dotenv',
  gh 'tpope/vim-dadbod',
  gh 'kristijanhusak/vim-dadbod-completion',
  gh 'kristijanhusak/vim-dadbod-ui',
}

require('which-key').add {
  { '<leader>D', group = '󰆼 Db Tools' },
  { '<leader>Df', '<cmd>DBUIFindBuffer<cr>', desc = ' DB UI Find buffer' },
  { '<leader>Dl', '<cmd>DBUILastQueryInfo<cr>', desc = ' DB UI Last query infos' },
  { '<leader>Dr', '<cmd>DBUIRenameBuffer<cr>', desc = ' DB UI Rename buffer' },
  { '<leader>DR', '<cmd>DopplerReloadDB<cr>', desc = ' Reload Doppler + DBUI' },
  { '<leader>Du', with_doppler(function() vim.cmd 'DBUIToggle' end), desc = ' DB UI Toggle' },
}

-- Remote development
vim.pack.add { { src = gh 'amitds1997/remote-nvim.nvim', version = 'main' } }
require('remote-nvim').setup {
  ssh_config = {
    scp_binary = 'rsync',
  },
  client_callback = function(port, workspace_config)
    local window_name = ('Remote: %s'):format(workspace_config.host)
    local cmd = ("tmux new-window -n '%s' 'nvim --server localhost:%s --remote-ui'"):format(window_name, port)
    vim.fn.jobstart(cmd, {
      detach = true,
      on_exit = function(job_id, exit_code, event_type) print('Client', job_id, 'exited with code', exit_code, 'Event type:', event_type) end,
    })
  end,
}

vim.keymap.set('n', '<leader>rs', '<CMD>RemoteStart<CR>', { desc = 'Start a remote Neovim' })
vim.keymap.set('n', '<leader>rS', '<CMD>RemoteStop<CR>', { desc = 'Stop a remote Neovim' })
vim.keymap.set('n', '<leader>ri', '<CMD>RemoteInfo<CR>', { desc = 'Remote Neovim Info' })
vim.keymap.set('n', '<leader>rl', '<CMD>RemoteLog<CR>', { desc = 'Remote Neovim Logs' })
vim.keymap.set('n', '<leader>rc', function()
  local input = vim.fn.input 'Enter the remote name: '
  if input and input ~= '' then
    vim.cmd('RemoteCleanup ' .. input)
  else
    print 'Remote name is required.'
  end
end, { desc = 'Cleanup a remote Neovim' })

-- Markdown preview (build step: `npm install` in app/, see PackChanged in init.lua)
-- <CUSTOM CHANGE> was lazy.nvim's `init`; mkdp reads this when sourced.
vim.g.mkdp_filetypes = { 'markdown' }
vim.pack.add { gh 'iamcco/markdown-preview.nvim' }
vim.keymap.set('n', '<leader>tm', '<CMD>MarkdownPreviewToggle<CR>', { desc = 'Toggle markdown preview' })

-- Claude Code (snacks.nvim comes from custom.plugins.editor)
vim.pack.add { gh 'coder/claudecode.nvim' }
require('claudecode').setup {
  terminal_cmd = '~/.local/bin/claude',
  terminal = {
    provider = 'snacks',
    snacks_win_opts = {
      position = 'float',
      width = 0.9,
      height = 0.9,
      border = 'rounded',
      keys = {
        claude_hide = {
          '<M-,>',
          function(self) self:hide() end,
          mode = 't',
          desc = 'Hide Claude Code',
        },
      },
    },
  },
}

require('which-key').add { { '<leader>a', group = 'AI/Claude Code' } }
vim.keymap.set('n', '<leader>ac', '<cmd>ClaudeCode<cr>', { desc = 'Toggle Claude' })
vim.keymap.set({ 'n', 'x' }, '<M-,>', '<cmd>ClaudeCodeFocus<cr>', { desc = 'Focus Claude' })
vim.keymap.set('n', '<leader>ar', '<cmd>ClaudeCode --resume<cr>', { desc = 'Resume Claude' })
vim.keymap.set('n', '<leader>aC', '<cmd>ClaudeCode --continue<cr>', { desc = 'Continue Claude' })
-- vim.keymap.set('n', '<leader>am', '<cmd>ClaudeCodeSelectModel<cr>', { desc = 'Select Claude model' })
vim.keymap.set('n', '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>', { desc = 'Add current buffer' })
vim.keymap.set('v', '<leader>as', '<cmd>ClaudeCodeSend<cr>', { desc = 'Send to Claude' })
-- Diff management
vim.keymap.set('n', '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>', { desc = 'Accept diff' })
vim.keymap.set('n', '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>', { desc = 'Deny diff' })

-- <CUSTOM CHANGE> lazy.nvim scoped this `<leader>as` variant to file-tree buffers via
-- `ft = {...}`; vim.pack has no such filter, so use a buffer-local FileType autocmd.
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'NvimTree', 'neo-tree', 'oil', 'minifiles', 'netrw' },
  group = vim.api.nvim_create_augroup('custom-claudecode-tree-add', { clear = true }),
  callback = function(args) vim.keymap.set('n', '<leader>as', '<cmd>ClaudeCodeTreeAdd<cr>', { buffer = args.buf, desc = 'Add file' }) end,
})

-- OpenFGA (build step installs the LSP server, see PackChanged in init.lua)
vim.pack.add { gh 'hedengran/fga.nvim' }
local fga_lsp_server = vim.fn.expand '~/.local/share/openfga-vscode-ext/server/out/server.node.js'
local fga_opts = { install_treesitter_grammar = true }
if vim.fn.filereadable(fga_lsp_server) == 1 then fga_opts.lsp_server = fga_lsp_server end
require('fga').setup(fga_opts)
