-- Python: debugging (DAP), venv selection, test running (neotest), REPL (iron)
--
-- NOTE (vim.pack): plugins load in the order they are added, and each needs an
-- explicit `setup()` -- lazy.nvim's `dependencies` and `opts` do not exist here.

local gh = function(repo) return 'https://github.com/' .. repo end

local function shorter_name(filename) return filename:gsub(os.getenv 'HOME', '~'):gsub('/bin/python', '') end

local function with_doppler(fn)
  return function()
    require('custom.doppler').load_env { force = true, sync = true }
    fn()
  end
end

-- <CUSTOM CHANGE> was lazy.nvim's `init` on nvim-dap: sign definitions must exist
-- before any breakpoint is placed.
vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl = 'DapBreakpoint', linehl = 'DapBreakpoint', numhl = 'DapBreakpoint' })
vim.fn.sign_define('DapBreakpointCondition', { text = 'ﳁ', texthl = 'DapBreakpoint', linehl = 'DapBreakpoint', numhl = 'DapBreakpoint' })

-- Debugger core. nvim-nio is required by both nvim-dap-ui and neotest.
vim.pack.add {
  gh 'nvim-neotest/nvim-nio',
  gh 'mfussenegger/nvim-dap',
  gh 'theHamsta/nvim-dap-virtual-text',
  gh 'rcarriga/nvim-dap-ui',
}
require('nvim-dap-virtual-text').setup {}

local dap = require 'dap'
local dapui = require 'dapui'
dapui.setup()
dap.listeners.after.event_initialized['dapui_config'] = function() dapui.open() end
dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end
dap.listeners.before.event_exited['dapui_config'] = function() dapui.close() end

vim.keymap.set('n', '<leader>db', '<cmd>DapToggleBreakpoint<CR>', { desc = 'Toggle debug breakpoint' })
vim.keymap.set(
  'n',
  '<leader>dC',
  "<cmd>lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition : '))<CR>",
  { desc = 'Set Conditional breakpoint' }
)
vim.keymap.set('n', '<leader>dc', with_doppler(function() vim.cmd 'DapContinue' end), { desc = 'Dap continue' })
vim.keymap.set('n', '<leader>di', '<cmd>DapStepInto<CR>', { desc = 'Dap step into' })
vim.keymap.set('n', '<leader>do', '<cmd>DapStepOut<CR>', { desc = 'Dap step out' })
vim.keymap.set('n', '<leader>dn', '<cmd>DapStepOver<CR>', { desc = 'Dap step over' })
vim.keymap.set('n', '<leader>dk', '<cmd>DapTerminate<CR>', { desc = 'Dap kill/terminate' })

vim.keymap.set('n', '<leader>dt', "<cmd>lua require('dapui').toggle()<CR>", { desc = 'DapUI Toggle' })
vim.keymap.set('n', '<leader>dr', "<cmd>lua require('dapui').open({reset = true})<CR>", { desc = 'Reset DapUI' })
vim.keymap.set(
  'n',
  '<leader>df',
  "<cmd>lua require('dapui').float_element(_, {height=40, width=80, position='center', enter=true})<CR>",
  { desc = 'Open element in a floating window' }
)
vim.keymap.set({ 'n', 'x' }, '<leader>de', "<CMD>lua require('dapui').eval()<CR><CMD>lua require('dapui').eval()<CR>", { desc = 'Dap Evaluate' })
-- New keymap to evaluate a custom expression entered by the user
vim.keymap.set('n', '<leader>dE', function()
  local expression = vim.fn.input 'Evaluate expression: '
  if expression and expression ~= '' then
    require('dapui').eval(expression)
    require('dapui').eval(expression)
  else
    print 'No expression provided.'
  end
end, { desc = 'Dap Evaluate Custom Expression' })

-- Python debugging
vim.pack.add { gh 'mfussenegger/nvim-dap-python' }
require('dap-python').setup 'uv'

local function target_python()
  local ok, venv = pcall(require, 'venv-selector')
  if ok then
    local p = venv.python()
    if p then return p end
  end
  return 'python3'
end

-- Use the active venv (via venv-selector) when dap-python launches pytest
-- test_method / test_class / debug_selection. Without this, dap-python would
-- fall back to its own detection. Matches what neotest does.
require('dap-python').resolve_python = target_python

local function infer_module()
  local buf = vim.api.nvim_buf_get_name(0)
  if buf == '' then return '' end
  local rel = vim.fn.fnamemodify(buf, ':.')
  rel = rel:gsub('^src/', ''):gsub('%.py$', ''):gsub('/__init__$', '')
  return (rel:gsub('/', '.'))
end

table.insert(dap.configurations.python, 1, {
  type = 'python',
  request = 'launch',
  name = 'Launch module',
  module = function() return vim.fn.input { prompt = 'Module: ', default = infer_module() } end,
  console = 'integratedTerminal',
  justMyCode = false,
  pythonPath = target_python,
  cwd = '${workspaceFolder}',
})

-- To save repeated prompts, drop a `.vscode/launch.json` in the project root.
-- It's the same format VS Code uses; nvim-dap reads it automatically on demand
-- (see `:help dap-providers`). No explicit loader call needed.
-- Each entry becomes a pickable choice in DAP when you hit <leader>dc.

vim.keymap.set('n', '<leader>dpm', "<cmd>lua require('dap-python').test_method()<CR>", { desc = 'Debug python method' })
vim.keymap.set('n', '<leader>dpc', "<cmd>lua require('dap-python').test_class()<CR>", { desc = 'Debug python class' })
vim.keymap.set('n', '<leader>dps', "<CMD>lua require('dap-python').debug_selection()<CR>", { desc = 'Debug python selection' })
vim.keymap.set('n', '<leader>dpM', function()
  require('custom.doppler').load_env { force = true, sync = true }
  dap.run(dap.configurations.python[1])
end, { desc = 'Debug python module' })

-- Virtualenv selection
vim.pack.add { gh 'linux-cultist/venv-selector.nvim' }
require('venv-selector').setup {
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
  options = { on_telescope_result_callback = shorter_name, override_notify = false },
}
vim.keymap.set('n', '<leader>v', '<cmd>VenvSelect<cr>')

-- <CUSTOM CHANGE> neotest: in-editor test runner with inline results, summary panel, DAP integration
vim.pack.add {
  gh 'antoinemadec/FixCursorHold.nvim',
  gh 'nvim-neotest/neotest-python',
  gh 'nvim-neotest/neotest',
}
require('neotest').setup {
  adapters = {
    require 'neotest-python' {
      runner = 'pytest',
      args = { '-vv' },
      python = function()
        local ok, venv = pcall(require, 'venv-selector')
        if ok then
          local python = venv.python()
          if python then return python end
        end
        return 'python3'
      end,
    },
  },
}

-- stylua: ignore start
vim.keymap.set('n', '<leader>tr', with_doppler(function() require('neotest').run.run() end),                       { desc = 'Run nearest test' })
vim.keymap.set('n', '<leader>tf', with_doppler(function() require('neotest').run.run(vim.fn.expand '%') end),      { desc = 'Run test file' })
vim.keymap.set('n', '<leader>ts', function() require('neotest').summary.toggle() end,                             { desc = 'Toggle test summary' })
vim.keymap.set('n', '<leader>to', function() require('neotest').output.open { enter_on_open = true } end,          { desc = 'Show test output' })
vim.keymap.set('n', '<leader>tO', function() require('neotest').output_panel.toggle() end,                         { desc = 'Toggle output panel' })
vim.keymap.set('n', '<leader>td', with_doppler(function() require('neotest').run.run { strategy = 'dap' } end),    { desc = 'Debug nearest test' })
vim.keymap.set('n', '<leader>tW', with_doppler(function() require('neotest').watch.toggle(vim.fn.expand '%') end), { desc = 'Watch test file' })
vim.keymap.set('n', '<leader>tS', function() require('neotest').run.stop() end,                                    { desc = 'Stop running tests' })
-- stylua: ignore end

-- REPL
vim.pack.add { gh 'Vigemus/iron.nvim' }
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

-- -- Global function to send 'pinfo' command for the entire line to IPython REPL
-- function _G.send_ipython_help()
--   local line = vim.fn.getline '.'
--   local pinfo_command = line .. '?'
--   iron.send(nil, { pinfo_command })
--   iron.send(nil, { '' })
--   vim.cmd 'IronFocus'
-- end

local function send_ipython_help_visual()
  local selected_text = vim.fn.getreg '"'
  if selected_text then
    selected_text = selected_text:gsub('^%s*(.-)%s*$', '%1')
    iron.send(nil, { selected_text .. '?' })
    iron.send(nil, { '' })
    vim.cmd 'IronFocus'
  end
end

vim.keymap.set('n', '<leader>ih', send_ipython_help_visual, { desc = 'Send selected text for documentation' })
vim.keymap.set('n', '<leader>it', '<cmd>IronRepl<cr>', { desc = 'Start REPL' })
vim.keymap.set('n', '<leader>ir', '<cmd>IronRestart<cr>', { desc = 'Restart REPL' })
vim.keymap.set('n', '<leader>if', '<cmd>IronFocus<cr>', { desc = 'Focus REPL' })

-- Embedded-language LSP (used for TOML with injected code)
vim.pack.add { gh 'jmbuhr/otter.nvim' }
vim.api.nvim_create_autocmd({ 'FileType' }, {
  pattern = { 'toml' },
  group = vim.api.nvim_create_augroup('EmbedToml', {}),
  callback = function() require('otter').activate() end,
})
