--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================
========                                    .-----.          ========
========         .----------------------.   | === |          ========
========         |.-""""""""""""""""""-.|   |-----|          ========
========         ||                    ||   | === |          ========
========         ||   KICKSTART.NVIM   ||   |-----|          ========
========         ||                    ||   | === |          ========
========         ||                    ||   |-----|          ========
========         ||:Tutor              ||   |:::::|          ========
========         |'-..................-'|   |____o|          ========
========         `"")----------------(""`   ___________      ========
========        /::::::::::|  |::::::::::\  \ no mouse \     ========
========       /:::========|  |==hjkl==:::\  \ required \    ========
========      '""""""""""""'  '""""""""""""'  '""""""""""'   ========
========                                                     ========
=====================================================================
=====================================================================

What is Kickstart?

  Kickstart.nvim is *not* a distribution.

  Kickstart.nvim is a starting point for your own configuration.
    The goal is that you can read every line of code, top-to-bottom, understand
    what your configuration is doing, and modify it to suit your needs.

    Once you've done that, you can start exploring, configuring and tinkering to
    make Neovim your own! That might mean leaving Kickstart just the way it is for a while
    or immediately breaking it into modular pieces. It's up to you!

    If you don't know anything about Lua, I recommend taking some time to read through
    a guide. One possible example which will only take 10-15 minutes:
      - https://learnxinyminutes.com/docs/lua/

    After understanding a bit more about Lua, you can use `:help lua-guide` as a
    reference for how Neovim integrates Lua.
    - :help lua-guide
    - (or HTML version): https://neovim.io/doc/user/lua-guide.html

Kickstart Guide:

  TODO: The very first thing you should do is to run the command `:Tutor` in Neovim.

    If you don't know what this means, type the following:
      - <escape key>
      - :
      - Tutor
      - <enter key>

    (If you already know the Neovim basics, you can skip this step.)

  Once you've completed that, you can continue working through **AND READING** the rest
  of the kickstart init.lua.

  Next, run AND READ `:help`.
    This will open up a help window with some basic information
    about reading, navigating and searching the builtin help documentation.

    This should be the first place you go to look when you're stuck or confused
    with something. It's one of my favorite Neovim features.

    MOST IMPORTANTLY, we provide a keymap "<space>sh" to [s]earch the [h]elp documentation,
    which is very useful when you're not exactly sure of what you're looking for.

  I have left several `:help X` comments throughout the init.lua
    These are hints about where to find more information about the relevant settings,
    plugins or Neovim features used in Kickstart.

   NOTE: Look for lines like this

    Throughout the file. These are for you, the reader, to help you understand what is happening.
    Feel free to delete them once you know what you're doing, but they should serve as a guide
    for when you are first encountering a few different constructs in your Neovim config.

If you experience any errors while trying to install kickstart, run `:checkhealth` for more info.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now! :)
--]]

-- ============================================================
-- SECTION 1: OPTIONS
-- Core Neovim settings, leaders, options, basic keymaps, basic autocmds
-- ============================================================
do
  -- Enable faster startup by caching compiled Lua modules
  vim.loader.enable()

  -- <CUSTOM CHANGE> Prepend mise shims to PATH so LSP/formatters/linters find mise-managed tools
  vim.env.PATH = vim.env.HOME .. '/.local/share/mise/shims:' .. vim.env.PATH

  -- Set <space> as the leader key
  -- See `:help mapleader`
  --  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '

  -- Set to true if you have a Nerd Font installed and selected in the terminal
  vim.g.have_nerd_font = true -- <CUSTOM CHANGE>

  -- [[ Setting options ]]
  --  See `:help vim.o`
  -- NOTE: You can change these options as you wish!
  --  For more options, you can see `:help option-list`

  -- Hightlight a column, good to know if you reached 80 characters for example
  vim.opt.colorcolumn = '100' -- <CUSTOM CHANGE>
  vim.opt_local.cursorcolumn = false
  -- Make line numbers default
  vim.o.number = true
  -- You can also add relative line numbers, to help with jumping.
  --  Experiment for yourself to see if you like it!
  vim.o.relativenumber = true -- <CUSTOM CHANGE>

  -- Enable mouse mode, can be useful for resizing splits for example!
  vim.o.mouse = 'a'

  -- Don't show the mode, since it's already in the status line
  vim.o.showmode = false

  -- Sync clipboard between OS and Neovim.
  --  Schedule the setting after `UiEnter` because it can increase startup-time.
  --  Remove this option if you want your OS clipboard to remain independent.
  --  See `:help 'clipboard'`
  -- <CUSTOM CHANGE>
  -- Use OSC 52 clipboard provider (works over SSH+tmux without xclip/xsel)
  vim.g.clipboard = {
    name = 'OSC 52',
    copy = {
      ['+'] = require('vim.ui.clipboard.osc52').copy '+',
      ['*'] = require('vim.ui.clipboard.osc52').copy '*',
    },
    paste = {
      ['+'] = require('vim.ui.clipboard.osc52').paste '+',
      ['*'] = require('vim.ui.clipboard.osc52').paste '*',
    },
  }
  vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

  -- Enable break indent
  vim.o.breakindent = true

  -- Enable undo/redo changes even after closing and reopening a file
  vim.o.undofile = true

  -- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
  vim.o.ignorecase = true
  vim.o.smartcase = true

  -- Keep signcolumn on by default
  vim.o.signcolumn = 'yes'

  -- Decrease update time
  vim.o.updatetime = 250

  -- Decrease mapped sequence wait time
  vim.o.timeoutlen = 300

  -- Configure how new splits should be opened
  vim.o.splitright = true
  vim.o.splitbelow = true

  -- Sets how neovim will display certain whitespace characters in the editor.
  --  See `:help 'list'`
  --  and `:help 'listchars'`
  --
  --  Notice listchars is set using `vim.opt` instead of `vim.o`.
  --  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
  --   See `:help lua-options`
  --   and `:help lua-guide-options`
  vim.o.list = true
  vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

  -- Preview substitutions live, as you type!
  vim.o.inccommand = 'split'

  -- Show which line your cursor is on
  vim.o.cursorline = true

  -- Minimal number of screen lines to keep above and below the cursor.
  vim.o.scrolloff = 10

  -- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
  -- instead raise a dialog asking if you wish to save the current file(s)
  -- See `:help 'confirm'`
  vim.o.confirm = true

  vim.opt.termguicolors = true -- needed for nvim-notify plugin --<CUSTOM CHANGE>

  -- -- Set foldmethod and foldexpr for Treesitter
  -- vim.wo.foldmethod = 'expr'
  -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  --
  -- -- Optional: Set the default fold level (e.g., to not fold by default)
  -- vim.wo.foldlevel = 99
end

-- ============================================================
-- SECTION 2: KEYMAPS
-- basic keymaps
-- ============================================================
do
  -- [[ Basic Keymaps ]]
  --  See `:help vim.keymap.set()`

  -- Clear highlights on search when pressing <Esc> in normal mode
  --  See `:help hlsearch`
  vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
  -- vim.opt.incsearch = true -- <CUSTOM CHANGE>

  vim.keymap.set('n', '<leader>pv', vim.cmd.Ex, { desc = 'Explore files <=> :Ex' }) -- <CUSTOM CHANGE>
  vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Keep the screen centered on the searched pattern' }) -- <CUSTOM CHANGE>
  vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Keep the screen centered on the searched pattern' }) -- <CUSTOM CHANGE>
  vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv") -- <CUSTOM CHANGE>
  vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv") -- <CUSTOM CHANGE>
  vim.keymap.set('n', 'J', 'mzJ`z') --<CUSTOM CHANGE>
  vim.keymap.set('x', '<leader>p', '"_dP') --<CUSTOM CHANGE>
  vim.keymap.set('v', '<leader>d', '"_d') --<CUSTOM CHANGE>
  vim.keymap.set('n', '<leader>ra', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]]) --<CUSTOM CHANGE>
  vim.keymap.set('n', '<leader>x<leader>', '<cmd>!chmod +x %<CR>', { desc = 'Make the file executable', silent = true }) --<CUSTOM CHANGE>
  vim.keymap.set('n', '<leader>ta', function()
    vim.opt.relativenumber = not vim.opt.relativenumber:get()
    vim.opt.number = true
  end, { noremap = true, silent = true, desc = '[T]oggle to [a]bsolute numbers' }) --<CUSTOM CHANGE>
  vim.keymap.set(
    'n',
    '<leader>tv',
    function() vim.opt_local.cursorcolumn = not vim.opt_local.cursorcolumn:get() end,
    { noremap = true, silent = true, desc = '[T]oggle to [v]ertical cursor column' }
  ) --<CUSTOM CHANGE>
  vim.keymap.set('i', 'jj', '<Esc>') --<CUSTOM CHANGE>
  vim.keymap.set('i', '<A-l>', '<Right>', { noremap = true, silent = true }) --<CUSTOM CHANGE>
  vim.keymap.set('i', '<A-h>', '<Left>', { noremap = true, silent = true }) --<CUSTOM CHANGE>
  vim.keymap.set('i', '<A-j>', '<C-o>gj', { noremap = true, silent = true }) --<CUSTOM CHANGE>
  vim.keymap.set('i', '<A-k>', '<C-o>gk', { noremap = true, silent = true }) --<CUSTOM CHANGE>
  vim.keymap.set('n', '<leader>tS', function()
    if vim.o.laststatus == 3 then
      vim.o.laststatus = 2
    else
      vim.o.laststatus = 3
    end
  end, { desc = '[T]oggle multi [s]tatus line' }) -- toggle multiple statusline for multiple windows

  -- Diagnostic Config & Keymaps
  --  See `:help vim.diagnostic.Opts`
  vim.diagnostic.config {
    update_in_insert = false,
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
    underline = { severity = { min = vim.diagnostic.severity.WARN } },

    -- Can switch between these as you prefer
    virtual_text = true, -- Text shows up at the end of the line
    virtual_lines = false, -- Text shows up underneath the line, with virtual lines

    -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
    jump = {
      on_jump = function(_, bufnr)
        vim.diagnostic.open_float {
          bufnr = bufnr,
          scope = 'cursor',
          focus = false,
        }
      end,
    },

    -- -- <CUSTOM CHANGE> nerd font diagnostic signs
    -- signs = vim.g.have_nerd_font and {
    --   text = {
    --     [vim.diagnostic.severity.ERROR] = '󰅚 ',
    --     [vim.diagnostic.severity.WARN] = '󰀪 ',
    --     [vim.diagnostic.severity.INFO] = '󰋽 ',
    --     [vim.diagnostic.severity.HINT] = '󰌶 ',
    --   },
    -- } or {},
  }

  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

  -- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
  -- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
  -- is not what someone will guess without a bit more experience.
  --
  -- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
  -- or just use <C-\><C-n> to exit terminal mode
  vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

  -- TIP: Disable arrow keys in normal mode
  -- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
  -- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
  -- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
  -- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

  -- Keybinds to make split navigation easier.
  --  Use CTRL+<hjkl> to switch between windows
  --
  --  See `:help wincmd` for a list of all window commands
  vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
  vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
  vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
  vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

  -- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
  -- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
  -- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
  -- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
  -- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

  -- -- Tab management --<CUSTOM CHANGE>
  -- vim.keymap.set('n', '<leader>to', '<cmd>tabnew<CR>', { desc = 'Open new tab' }) --<CUSTOM CHANGE>
  -- vim.keymap.set('n', '<leader>tx', '<cmd>tabclose<CR>', { desc = 'Close current tab' }) --<CUSTOM CHANGE>
  -- vim.keymap.set('n', '<leader>tn', '<cmd>tabn<CR>', { desc = 'Go to next tab' }) --<CUSTOM CHANGE>
  -- vim.keymap.set('n', '<leader>tp', '<cmd>tabp<CR>', { desc = 'Go to previous tab' }) --<CUSTOM CHANGE>
  -- vim.keymap.set('n', '<leader>tf', '<cmd>tabnew %<CR>', { desc = 'Open current buffer in a new tab' }) --<CUSTOM CHANGE>

  -- Buffer management
  vim.keymap.set('n', '<leader>bl', '<cmd>bnext<CR>', { desc = 'Next Buffer' }) --<CUSTOM CHANGE>
  vim.keymap.set('n', '<leader>bh', '<cmd>bprev<CR>', { desc = 'Previous Buffer' }) --<CUSTOM CHANGE>
  vim.keymap.set('n', '<leader>bL', '<cmd>blast<CR>', { desc = 'Last Buffer' }) --<CUSTOM CHANGE>
  vim.keymap.set('n', '<leader>bH', '<cmd>bfirst<CR>', { desc = 'First Buffer' }) --<CUSTOM CHANGE>
  vim.keymap.set('n', '<leader>bd', '<cmd>bdelete<CR>', { desc = 'Delete Buffer' }) --<CUSTOM CHANGE>
  vim.keymap.set('n', '<leader>bD', '<cmd>bdelete!<CR>', { desc = 'Force Deleting Buffer' }) --<CUSTOM CHANGE>
  vim.keymap.set('n', '<leader>bp', '<cmd>b#<CR>', { desc = 'Go back to the previous Buffer' }) --<CUSTOM CHANGE>

  -- [[ Basic Autocommands ]]
  --  See `:help lua-guide-autocommands`

  -- Highlight when yanking (copying) text
  --  Try it with `yap` in normal mode
  --  See `:help vim.hl.on_yank()`
  vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function() vim.hl.on_yank() end,
  })

  -- <CUSTOM CHANGE> Python: <leader>mi appends `# type: ignore[<code>]` for mypy diagnostics on the current line
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'python',
    group = vim.api.nvim_create_augroup('custom-python-mypy-ignore', { clear = true }),
    callback = function(args)
      vim.keymap.set('n', '<leader>mi', function()
        local row = vim.api.nvim_win_get_cursor(0)[1]
        local codes = {}
        for _, d in ipairs(vim.diagnostic.get(args.buf, { lnum = row - 1 })) do
          if d.source == 'mypy' and d.code then table.insert(codes, d.code) end
        end
        if #codes == 0 then
          vim.notify('no mypy diagnostic on this line', vim.log.levels.WARN)
          return
        end
        local line = vim.api.nvim_buf_get_lines(args.buf, row - 1, row, false)[1]
        local ignore = '# type: ignore[' .. table.concat(codes, ', ') .. ']'

        -- Treesitter tells us the column of the first real `#` (ignoring `#` inside string literals).
        local ok, parser = pcall(vim.treesitter.get_parser, args.buf, 'python')
        if not ok or not parser then
          vim.notify('Treesitter python parser unavailable', vim.log.levels.ERROR)
          return
        end
        local tree = parser:parse()[1]
        local query = vim.treesitter.query.parse('python', '(comment) @c')
        local first_col
        for _, node in query:iter_captures(tree:root(), args.buf, row - 1, row) do
          local sr, sc = node:range()
          if sr == row - 1 and (not first_col or sc < first_col) then first_col = sc end
        end

        local code_part, trailing
        if not first_col then
          code_part, trailing = line:gsub('%s+$', ''), ''
        else
          code_part = line:sub(1, first_col):gsub('%s+$', '')
          -- Python sees `# type: ignore[X]  # noqa: Y` as one comment token; strip the ignore chunk out of the blob
          trailing = line:sub(first_col + 1):gsub('#%s*type:%s*ignore%[.-%]', '')
          trailing = trailing:gsub('^%s+', ''):gsub('%s+$', ''):gsub('%s%s+', '  ')
        end

        local new_line = code_part .. '  ' .. ignore
        if trailing ~= '' then new_line = new_line .. '  ' .. trailing end
        vim.api.nvim_buf_set_lines(args.buf, row - 1, row, false, { new_line })
      end, { buffer = args.buf, desc = 'Python: mypy type:ignore this line' })
    end,
  })
end

-- ============================================================
-- SECTION 3: PLUGIN MANAGER INTRO
-- vim.pack intro, build hooks
-- ============================================================
do
  -- [[ Intro to `vim.pack` ]]
  -- `vim.pack` is a new plugin manager built into Neovim,
  --  which provides a Lua interface for installing and managing plugins.
  --
  --  See `:help vim.pack`, `:help vim.pack-examples` or the
  --  excellent blog post from the creator of vim.pack and mini.nvim:
  --  https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack
  --
  --  To inspect plugin state and pending updates, run
  --    :lua vim.pack.update(nil, { offline = true })
  --
  --  To update plugins, run
  --    :lua vim.pack.update()
  --
  --
  --  Throughout the rest of the config there will be examples
  --  of how to install and configure plugins using `vim.pack`.
  --
  --  In this section we set up some autocommands to run build
  --  steps for certain plugins after they are installed or updated.

  local function run_build(name, cmd, cwd)
    local result = vim.system(cmd, { cwd = cwd }):wait()
    if result.code ~= 0 then
      local stderr = result.stderr or ''
      local stdout = result.stdout or ''
      local output = stderr ~= '' and stderr or stdout
      if output == '' then output = 'No output from build command.' end
      vim.notify(('Build failed for %s:\n%s'):format(name, output), vim.log.levels.ERROR)
    end
  end

  -- This autocommand runs after a plugin is installed or updated and
  --  runs the appropriate build command for that plugin if necessary.
  --
  -- See `:help vim.pack-events`
  vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
      local name = ev.data.spec.name
      local kind = ev.data.kind
      if kind ~= 'install' and kind ~= 'update' then return end

      if name == 'telescope-fzf-native.nvim' and vim.fn.executable 'make' == 1 then
        run_build(name, { 'make' }, ev.data.path)
        return
      end

      if name == 'LuaSnip' then
        if vim.fn.has 'win32' ~= 1 and vim.fn.executable 'make' == 1 then run_build(name, { 'make', 'install_jsregexp' }, ev.data.path) end
        return
      end

      if name == 'nvim-treesitter' then
        if not ev.data.active then vim.cmd.packadd 'nvim-treesitter' end
        vim.cmd 'TSUpdate'
        return
      end

      -- <CUSTOM CHANGE> was lazy.nvim's `build = 'cd app && npm install'`
      if name == 'markdown-preview.nvim' then
        if vim.fn.executable 'npm' == 1 then run_build(name, { 'npm', 'install' }, vim.fs.joinpath(ev.data.path, 'app')) end
        return
      end

      -- <CUSTOM CHANGE> was lazy.nvim's `build` function on fga.nvim: fetch and compile
      -- the OpenFGA VS Code extension, which ships the LSP server fga.nvim talks to.
      if name == 'fga.nvim' then
        local lsp_dir = vim.fn.expand '~/.local/share/openfga-vscode-ext'
        local lsp_server = lsp_dir .. '/server/out/server.node.js'
        if vim.fn.filereadable(lsp_server) == 0 then
          vim.notify('fga.nvim: Installing FGA LSP server...', vim.log.levels.INFO)
          local cmds = string.format(
            'git clone https://github.com/openfga/vscode-ext %s && cd %s && npm install && npm run compile',
            vim.fn.shellescape(lsp_dir),
            vim.fn.shellescape(lsp_dir)
          )
          local result = vim.fn.system(cmds)
          if vim.v.shell_error == 0 then
            vim.notify('fga.nvim: FGA LSP server installed successfully', vim.log.levels.INFO)
          else
            vim.notify('fga.nvim: Failed to install FGA LSP server:\n' .. result, vim.log.levels.ERROR)
          end
        end
        return
      end
    end,
  })

  -- <CUSTOM CHANGE> `:Lazy`-style entry points for vim.pack.
  --  Both open the same confirmation buffer (`:w` to confirm, `:q` to discard,
  --  `]]`/`[[` to navigate, `K` for details, `gra` for per-plugin actions).
  local function pack_names()
    return vim.tbl_map(function(p) return p.spec.name end, vim.pack.get())
  end

  vim.api.nvim_create_user_command('PackList', function() vim.pack.update(nil, { offline = true }) end, {
    desc = 'List installed plugins (vim.pack, no network)',
  })

  vim.api.nvim_create_user_command('PackUpdate', function(opts)
    local names = #opts.fargs > 0 and opts.fargs or nil
    vim.pack.update(names, { force = opts.bang })
  end, {
    desc = 'Update plugins (vim.pack); ! skips the confirmation buffer',
    nargs = '*',
    bang = true,
    complete = function(arg_lead) return vim.tbl_filter(function(n) return vim.startswith(n, arg_lead) end, pack_names()) end,
  })
end

---Because most plugins are hosted on GitHub, you can use the helper
---function to have less repetition in the following sections.
---@param repo string
---@return string
local function gh(repo) return 'https://github.com/' .. repo end

-- ============================================================
-- SECTION 4: UI / CORE UX PLUGINS
-- guess-indent, gitsigns, which-key, colorscheme, todo-comments, mini modules
-- ============================================================
do
  -- [[ Installing and Configuring Plugins ]]
  --
  -- To install a plugin simply call `vim.pack.add` with its git url.
  -- This will download the default branch of the plugin, which will usually be `main` or `master`
  -- You can also have more advanced specs, which we will talk about later.
  --
  -- For most plugins its not enough to install them, you also need to call their `.setup()` to start them.
  --
  -- For example, lets say we want to install `guess-indent.nvim` - a plugin for
  -- automatically detecting and setting the indentation.
  --
  -- We first install it from https://github.com/NMAC427/guess-indent.nvim
  -- and then call its `setup()` function to start it with default settings.
  vim.pack.add { gh 'NMAC427/guess-indent.nvim' }
  require('guess-indent').setup {}

  -- Here is a more advanced configuration example that passes options to `gitsigns.nvim`
  --
  -- See `:help gitsigns` to understand what each configuration key does.
  -- Adds git related signs to the gutter, as well as utilities for managing changes
  vim.pack.add { gh 'lewis6991/gitsigns.nvim' }
  require('gitsigns').setup {
    signs = {
      add = { text = '+' }, ---@diagnostic disable-line: missing-fields
      change = { text = '~' }, ---@diagnostic disable-line: missing-fields
      delete = { text = '_' }, ---@diagnostic disable-line: missing-fields
      topdelete = { text = '‾' }, ---@diagnostic disable-line: missing-fields
      changedelete = { text = '~' }, ---@diagnostic disable-line: missing-fields
    },
    current_line_blame = true, -- <CUSTOM CHANGE>
  }

  -- Useful plugin to show you pending keybinds.
  vim.pack.add { gh 'folke/which-key.nvim' }
  require('which-key').setup {
    -- Delay between pressing a key and opening which-key (milliseconds)
    delay = 0,
    icons = { mappings = vim.g.have_nerd_font },
    -- Document existing key chains
    spec = {
      { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
      { '<leader>t', group = '[T]oggle' },
      { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } }, -- Enable gitsigns recommended keymaps first
      { 'gr', group = 'LSP Actions', mode = { 'n' } },
      { '<leader>b', group = '[B]uffer' }, -- <CUSTOM CHANGE>
    },
  }

  -- [[ Colorscheme ]]
  -- You can easily change to a different colorscheme.
  -- Change the name of the colorscheme plugin below, and then
  -- change the command under that to load whatever the name of that colorscheme is.
  --
  -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
  vim.pack.add { gh 'folke/tokyonight.nvim' }
  ---@diagnostic disable-next-line: missing-fields
  require('tokyonight').setup {
    styles = {
      comments = { italic = false }, -- Disable italics in comments
    },
  }

  -- Load the colorscheme here.
  -- Like many other themes, this one has different styles, and you could load
  -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
  vim.cmd.colorscheme 'tokyonight-night'

  -- Highlight todo, notes, etc in comments
  vim.pack.add { gh 'folke/todo-comments.nvim' }
  require('todo-comments').setup { signs = false }

  -- [[ mini.nvim ]]
  --  A collection of various small independent plugins/modules
  vim.pack.add { gh 'nvim-mini/mini.nvim' }

  -- If a nerd font is available, load the icons module for pretty icons in various plugins.
  if vim.g.have_nerd_font then
    require('mini.icons').setup()
    -- Used for backwards compatibility with plugins that require `nvim-web-devicons` (e.g. telescope.nvim)
    MiniIcons.mock_nvim_web_devicons()
  end

  -- Better Around/Inside textobjects
  --
  -- Examples:
  --  - va)  - [V]isually select [A]round [)]paren
  --  - yiiq - [Y]ank [I]nside [I]+1 [Q]uote
  --  - ci'  - [C]hange [I]nside [']quote
  require('mini.ai').setup {
    -- NOTE: Avoid conflicts with the built-in incremental selection mappings on Neovim>=0.12 (see `:help treesitter-incremental-selection`)
    mappings = {
      around_next = 'aa',
      inside_next = 'ii',
    },
    n_lines = 500,
  }

  -- Add/delete/replace surroundings (brackets, quotes, etc.)
  --
  -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
  -- - sd'   - [S]urround [D]elete [']quotes
  -- - sr)'  - [S]urround [R]eplace [)] [']
  -- require('mini.surround').setup() -- <CUSTOM CHANGE> disabled in favour of tpope/vim-surround

  -- Simple and easy statusline.
  --  You could remove this setup call if you don't like it,
  --  and try some other statusline plugin
  local statusline = require 'mini.statusline'
  -- Set `use_icons` to true if you have a Nerd Font
  statusline.setup { use_icons = vim.g.have_nerd_font }

  -- You can configure sections in the statusline by overriding their
  -- default behavior. For example, here we set the section for
  -- cursor location to LINE:COLUMN
  ---@diagnostic disable-next-line: duplicate-set-field
  statusline.section_location = function() return '%2l:%-2v' end

  -- ... and there is more!
  --  Check out: https://github.com/nvim-mini/mini.nvim
end

-- ============================================================
-- SECTION 5: SEARCH & NAVIGATION
-- Telescope setup, keymaps, LSP picker mappings
-- ============================================================
do
  -- [[ Fuzzy Finder (files, lsp, etc) ]]
  --
  -- Telescope is a fuzzy finder that comes with a lot of different things that
  -- it can fuzzy find! It's more than just a "file finder", it can search
  -- many different aspects of Neovim, your workspace, LSP, and more!
  --
  -- There are lots of other alternative pickers (like snacks.picker, or fzf-lua)
  -- so feel free to experiment and see what you like!
  --
  -- The easiest way to use Telescope, is to start by doing something like:
  --  :Telescope help_tags
  --
  -- After running this command, a window will open up and you're able to
  -- type in the prompt window. You'll see a list of `help_tags` options and
  -- a corresponding preview of the help.
  --
  -- Two important keymaps to use while in Telescope are:
  --  - Insert mode: <c-/>
  --  - Normal mode: ?
  --
  -- This opens a window that shows you all of the keymaps for the current
  -- Telescope picker. This is really useful to discover what Telescope can
  -- do as well as how to actually do it!

  ---@type (string|vim.pack.Spec)[]
  local telescope_plugins = {
    gh 'nvim-lua/plenary.nvim',
    gh 'nvim-telescope/telescope.nvim',
    gh 'nvim-telescope/telescope-ui-select.nvim',
  }
  if vim.fn.executable 'make' == 1 then table.insert(telescope_plugins, gh 'nvim-telescope/telescope-fzf-native.nvim') end

  -- NOTE: You can install multiple plugins at once
  vim.pack.add(telescope_plugins)

  -- See `:help telescope` and `:help telescope.setup()`
  require('telescope').setup {
    -- You can put your default mappings / updates / etc. in here
    --  All the info you're looking for is in `:help telescope.setup()`
    --
    -- <CUSTOM CHANGE> normal-mode `d` deletes a buffer from the picker, `q` closes it
    defaults = {
      mappings = {
        -- i = { ['<c-enter>'] = 'to_fuzzy_refine' },
        n = {
          ['d'] = require('telescope.actions').delete_buffer,
          ['q'] = require('telescope.actions').close,
        },
      },
    },
    extensions = {
      ['ui-select'] = { require('telescope.themes').get_dropdown() },
    },

    -- <CUSTOM CHANGE> search hidden files (excluding .git) by default
    pickers = {
      find_files = { find_command = { 'fd', '--type', 'f', '--color', 'never', '--hidden', '--exclude', '.git' } },
      live_grep = { additional_args = { '--hidden', '--glob', '!.git' } },
      grep_string = { additional_args = { '--hidden', '--glob', '!.git' } },
    },
  }

  -- Enable Telescope extensions if they are installed
  pcall(require('telescope').load_extension, 'fzf')
  pcall(require('telescope').load_extension, 'ui-select')

  -- See `:help telescope.builtin`
  local builtin = require 'telescope.builtin'
  vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
  vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
  -- <CUSTOM CHANGE> include hidden files and follow symlinks
  vim.keymap.set('n', '<leader>sf', function() builtin.find_files { hidden = true, follow = true } end, { desc = '[S]earch [F]iles' })
  vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
  -- <CUSTOM CHANGE> searches hidden files and follows symlinks (was `{ 'n', 'v' }` + bare builtin)
  vim.keymap.set('n', '<leader>sw', function()
    builtin.grep_string {
      additional_args = function(opts) return { '--hidden', '--glob', '!.git', '--follow' } end,
    }
  end, { desc = '[S]earch current [W]ord' })

  -- <CUSTOM CHANGE> searches hidden files and follows symlinks
  vim.keymap.set('n', '<leader>sg', function()
    builtin.live_grep {
      additional_args = function(opts) return { '--hidden', '--glob', '!.git', '--follow' } end,
    }
  end, { desc = '[S]earch by [G]rep' })
  vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
  vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
  vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
  vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })
  vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
  vim.keymap.set('n', '<leader>st', '<cmd>TodoTelescope<CR>', { desc = '[S]earch [T]odo comments' }) -- <CUSTOM CHANGE>

  -- Add Telescope-based LSP pickers when an LSP attaches to a buffer.
  -- If you later switch picker plugins, this is where to update these mappings.
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
    callback = function(event)
      local buf = event.buf

      -- Find references for the word under your cursor.
      vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })

      -- Jump to the implementation of the word under your cursor.
      -- Useful when your language has ways of declaring types without an actual implementation.
      vim.keymap.set('n', 'gri', builtin.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })

      -- Jump to the definition of the word under your cursor.
      -- This is where a variable was first declared, or where a function is defined, etc.
      -- To jump back, press <C-t>.
      vim.keymap.set('n', 'grd', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })

      -- Fuzzy find all the symbols in your current document.
      -- Symbols are things like variables, functions, types, etc.
      vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'Open Document Symbols' })

      -- Fuzzy find all the symbols in your current workspace.
      -- Similar to document symbols, except searches over your entire project.
      vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })

      -- Jump to the type of the word under your cursor.
      -- Useful when you're not sure what type a variable is and you want to see
      -- the definition of its *type*, not where it was *defined*.
      vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })
    end,
  })

  -- Override default behavior and theme when searching
  vim.keymap.set('n', '<leader>/', function()
    -- You can pass additional configuration to Telescope to change the theme, layout, etc.
    builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
      winblend = 10,
      previewer = false,
    })
  end, { desc = '[/] Fuzzily search in current buffer' })

  -- It's also possible to pass additional configuration options.
  --  See `:help telescope.builtin.live_grep()` for information about particular keys
  vim.keymap.set(
    'n',
    '<leader>s/',
    function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end,
    { desc = '[S]earch [/] in Open Files' }
  )

  -- Shortcut for searching your Neovim configuration files
  vim.keymap.set('n', '<leader>sn', function() builtin.find_files { cwd = vim.fn.stdpath 'config', follow = true } end, { desc = '[S]earch [N]eovim files' })

  -- <CUSTOM CHANGE> picker that jumps to `# --- section ---` markers in the current buffer
  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local conf = require('telescope.config').values
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'

  vim.keymap.set('n', '<leader>sb', function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local entries = {}
    for i, line in ipairs(lines) do
      if line:match '^#%s*%-%-%-.*%-%-%-' then table.insert(entries, { line = line, lnum = i }) end
    end

    pickers
      .new({}, {
        prompt_title = 'Section Markers',
        finder = finders.new_table {
          results = entries,
          entry_maker = function(entry)
            return {
              value = entry,
              display = entry.line,
              ordinal = entry.line,
            }
          end,
        },
        sorter = conf.generic_sorter {},
        previewer = false, -- disable preview
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            vim.api.nvim_win_set_cursor(0, { selection.value.lnum, 0 })
          end)
          return true
        end,
      })
      :find()
  end, { desc = 'Jump to # --- section' })
end

-- ============================================================
-- SECTION 6: LSP
-- LSP keymaps, server configuration, Mason tools installations
-- ============================================================
do
  -- [[ LSP Configuration ]]
  -- Brief aside: **What is LSP?**
  --
  -- LSP is an initialism you've probably heard, but might not understand what it is.
  --
  -- LSP stands for Language Server Protocol. It's a protocol that helps editors
  -- and language tooling communicate in a standardized fashion.
  --
  -- In general, you have a "server" which is some tool built to understand a particular
  -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
  -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
  -- processes that communicate with some "client" - in this case, Neovim!
  --
  -- LSP provides Neovim with features like:
  --  - Go to definition
  --  - Find references
  --  - Autocompletion
  --  - Symbol Search
  --  - and more!
  --
  -- Thus, Language Servers are external tools that must be installed separately from
  -- Neovim. This is where `mason` and related plugins come into play.
  --
  -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
  -- and elegantly composed help section, `:help lsp-vs-treesitter`

  -- Useful status updates for LSP.
  vim.pack.add { gh 'j-hui/fidget.nvim' }
  require('fidget').setup {}

  --  This function gets run when an LSP attaches to a particular buffer.
  --    That is to say, every time a new file is opened that is associated with
  --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
  --    function will be executed to configure the current buffer
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
    callback = function(event)
      -- NOTE: Remember that Lua is a real programming language, and as such it is possible
      -- to define small helper and utility functions so you don't have to repeat yourself.
      --
      -- In this case, we create a function that lets us more easily define mappings specific
      -- for LSP related items. It sets the mode, buffer and description for us each time.
      local map = function(keys, func, desc, mode)
        mode = mode or 'n'
        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
      end

      -- Rename the variable under your cursor.
      --  Most Language Servers support renaming across files, etc.
      map('grn', vim.lsp.buf.rename, '[R]e[n]ame')

      -- Execute a code action, usually your cursor needs to be on top of an error
      -- or a suggestion from your LSP for this to activate.
      map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

      -- WARN: This is not Goto Definition, this is Goto Declaration.
      --  For example, in C this would take you to the header.
      map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

      -- The following two autocommands are used to highlight references of the
      -- word under your cursor when your cursor rests there for a little while.
      --    See `:help CursorHold` for information about when this is executed
      --
      -- When you move your cursor, the highlights will be cleared (the second autocommand).
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if client and client:supports_method('textDocument/documentHighlight', event.buf) then
        local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.document_highlight,
        })

        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.clear_references,
        })

        vim.api.nvim_create_autocmd('LspDetach', {
          group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
          callback = function(event2)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
          end,
        })
      end

      -- The following code creates a keymap to toggle inlay hints in your
      -- code, if the language server you are using supports them
      --
      -- This may be unwanted, since they displace some of your code
      if client and client:supports_method('textDocument/inlayHint', event.buf) then
        map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[T]oggle Inlay [H]ints')
      end
    end,
  })

  -- <CUSTOM CHANGE> schemastore must be on the runtimepath *before* the `servers` table below is
  -- constructed, because the `jsonls` entry calls `require('schemastore')` at construction time.
  -- lazy.nvim resolved this via `dependencies`; vim.pack.add is ordered, so we add it up front.
  vim.pack.add { gh 'b0o/schemastore.nvim' }

  -- Enable the following language servers
  --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
  --  See `:help lsp-config` for information about keys and how to configure
  ---@type table<string, vim.lsp.Config>
  local servers = {
    -- <CUSTOM CHANGE> our full server set begins here (through `yamlls`)
    -- isort = {},
    -- black = {},
    -- pylint = {},
    prettier = {}, -- <CUSTOM CHANGE> not an LSP; listed so mason-tool-installer installs it (same trick upstream uses for `stylua`)
    jsonls = {
      settings = {
        json = {
          schemas = require('schemastore').json.schemas(),
          -- schemas = vim.list_extend(
          --   require('schemastore').json.schemas(), --  Load all known schemas
          --   {
          --     {
          --       fileMatch = { '.renovaterc', '.renovaterc.json' },
          --       url = 'https://docs.renovatebot.com/renovate-schema.json',
          --     },
          --   }
          -- ),
          validate = { enable = true },
          -- resultLimit = 10000, -- Optional: avoid missing large schemas
        },
      },
      filetypes = { 'json', 'jsonc', 'json5' },
    },
    -- taplo = {},
    ruff = {},
    bashls = {},
    -- pylsp = {
    --   settings = {
    --     -- configurationSources = { 'flake8' },
    --     pylsp = {
    --       plugins = {
    --         ruff = {
    --           enabled = true,
    --           formatEnabled = true,
    --           config = '~/.config/ruff/ruff.toml',
    --           format = { 'I', 'F541' },
    --           unsafeFixes = true,
    --         },
    --         pycodestyle = { enabled = false },
    --         mccabe = { enabled = false },
    --         pyflakes = { enabled = false },
    --         autopep8 = { enabled = false },
    --         flake8 = { enabled = false },
    --         isort = { enabled = false },
    --         black = { enabled = false },
    --         pylsp_rope = { enabled = false },
    --         pylint = { enabled = false },
    --         yapf = { enabled = false },
    --         pylsp_mypy = {
    --           enabled = true,
    --           dmypy = true,
    --           live_mode = false,
    --           report_progress = true,
    --           overrides = {
    --             true,
    --             '--ignore-missing-imports', -- Add the same flag you would use in mypy.ini
    --           },
    --         },
    --       },
    --     },
    --   },
    -- },
    -- basedpyright = {
    --   settings = {
    --     basedpyright = {
    --       disableOrganizeImports = true,
    --       disableTaggedHints = true,
    --       analysis = {
    --         autoSearchPaths = true,
    --         diagnosticMode = 'openFilesOnly',
    --         useLibraryCodeForTypes = true,
    --         inlayHints = { callArgumentNames = true },
    --         typeCheckingMode = 'off',
    --       },
    --     },
    --   },
    -- },
    pyright = {},
    -- pyright = {
    --   -- -- autostart = false,
    --   -- on_attach = function(client, bufnr)
    --   --   if client.name == 'pyright' then
    --   --     -- Disable auto-completion
    --   --     -- client.server_capabilities.completionProvider = nil
    --   --     client.server_capabilities.completionProvider = nil
    --   --
    --   --     -- Disable code navigation capabilities
    --   --     client.server_capabilities.definitionProvider = false
    --   --     client.server_capabilities.declarationProvider = false
    --   --     client.server_capabilities.implementationProvider = false
    --   --     client.server_capabilities.referencesProvider = false
    --   --     client.server_capabilities.documentSymbolProvider = false
    --   --     client.server_capabilities.workspaceSymbolProvider = false
    --   --     client.server_capabilities.typeDefinitionProvider = false
    --   --     client.server_capabilities.signatureHelpProvider = false
    --   --     client.server_capabilities.renameProvider = false
    --   --     client.server_capabilities.codeActionProvider = false
    --   --     client.server_capabilities.formattingProvider = false
    --   --     -- client.server_capabilities.documentHighlightProvider = false
    --   --     client.server_capabilities.semanticTokensProvider = false
    --   --
    --   --     -- Leave hoverProvider enabled so that 'K' shows type info
    --   --     client.server_capabilities.hoverProvider = true
    --   --   end
    --   -- end,
    --   settings = {
    --     pyright = {
    --       disableOrganizeImports = true,
    --       disableTaggedHints = true,
    --     },
    --     python = {
    --       analysis = {
    --         autoSearchPaths = true,
    --         diagnosticMode = 'openFilesOnly', -- Disables diagnostics
    --         diagnosticSeverityOverrides = {
    --           --   reportMissingModuleSource = 'none',
    --           --   reportMissingImports = 'none',
    --           reportUndefinedVariable = 'none',
    --         },
    --         useLibraryCodeForTypes = true,
    --         typeCheckingMode = 'off',
    --       },
    --     },
    --   },
    -- },
    ansiblels = {},
    docker_compose_language_service = {},
    dockerls = {},
    gitlab_ci_ls = {},
    -- grammarly = {},
    helm_ls = {},
    jqls = {},
    markdown_oxide = {},
    -- pylyzer = {},
    sqlls = {},
    yamlls = {
      settings = {
        yaml = {
          schemas = {
            ['https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.34.1-standalone-strict/all.json'] = {
              '**/*.k8s.{yml,yaml}',
              'k8s/**/*.{yml,yaml}',
              'manifests/**/*.{yml,yaml}',
            },
            ['https://json.schemastore.org/github-workflow.json'] = '/.github/workflows/*',
            ['https://json.schemastore.org/pre-commit-config.json'] = '/.pre-commit-config.yaml',
            ['https://json.schemastore.org/gitlab-ci'] = '*gitlab-ci*.{yml,yaml}',
            ['http://json.schemastore.org/ansible-playbook'] = '*play*.{yml,yaml}',
            ['http://json.schemastore.org/chart'] = 'Chart.{yml,yaml}',
            ['https://json.schemastore.org/dependabot-v2'] = '.github/dependabot.{yml,yaml}',
            ['https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json'] = {
              '*docker-compose*.{yml,yaml}',
              '*compose*.{yml,yaml}',
            },
            ['https://raw.githubusercontent.com/argoproj/argo-workflows/master/api/jsonschema/schema.json'] = '*flow*.{yml,yaml}',
            -- ['http://json.schemastore.org/kustomization'] = 'kustomization.{yml,yaml}',
          },
        },
      },
    },
    -- <CUSTOM CHANGE> end of our server set
    -- clangd = {},
    -- gopls = {},
    -- rust_analyzer = {},
    --
    -- Some languages (like typescript) have entire language plugins that can be useful:
    --    https://github.com/pmizio/typescript-tools.nvim
    --
    -- But for many setups, the LSP (`ts_ls`) will work just fine
    -- ts_ls = {},

    stylua = {}, -- Used to format Lua code

    -- Special Lua Config, as recommended by neovim help docs
    lua_ls = {
      on_init = function(client)
        client.server_capabilities.documentFormattingProvider = false -- Disable formatting (formatting is done by stylua)

        if client.workspace_folders then
          local path = client.workspace_folders[1].name
          if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
        end

        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
          runtime = {
            version = 'LuaJIT',
            path = { 'lua/?.lua', 'lua/?/init.lua' },
          },
          workspace = {
            checkThirdParty = false,
            -- NOTE: this is a lot slower and will cause issues when working on your own configuration.
            --  See https://github.com/neovim/nvim-lspconfig/issues/3189
            library = vim.tbl_extend('force', vim.api.nvim_get_runtime_file('', true), {
              '${3rd}/luv/library',
              '${3rd}/busted/library',
            }),
          },
        })
      end,
      ---@type lspconfig.settings.lua_ls
      settings = {
        Lua = {
          format = { enable = false }, -- Disable formatting (formatting is done by stylua)
        },
      },
    },
  }

  vim.pack.add {
    gh 'neovim/nvim-lspconfig',
    gh 'mason-org/mason.nvim',
    gh 'mason-org/mason-lspconfig.nvim',
    gh 'WhoIsSethDaniel/mason-tool-installer.nvim',
    -- NOTE: schemastore.nvim is added earlier, above the `servers` table -- see the <CUSTOM CHANGE> note there
  }

  -- Automatically install LSPs and related tools to stdpath for Neovim
  require('mason').setup {
    max_concurrent_installers = 2, -- <CUSTOM CHANGE>
  }

  -- Ensure the servers and tools above are installed
  --
  -- To check the current status of installed tools and/or manually install
  -- other tools, you can run
  --    :Mason
  --
  -- You can press `g?` for help in this menu.
  local ensure_installed = vim.tbl_keys(servers or {})
  vim.list_extend(ensure_installed, {
    -- <CUSTOM CHANGE> tools that aren't LSP servers
    -- Formatters (conform.nvim)
    'stylua',
    'prettier',
    'shfmt',
    -- Linters (nvim-lint)
    'markdownlint',
    'checkmake',
    'mypy',
  })

  require('mason-tool-installer').setup { ensure_installed = ensure_installed }

  -- <CUSTOM CHANGE> foldingRange capability for nvim-ufo (plugin arrives in Phase 3)
  vim.lsp.config('*', {
    capabilities = {
      textDocument = {
        foldingRange = {
          dynamicRegistration = false,
          lineFoldingOnly = true,
        },
      },
    },
  })

  for name, server in pairs(servers) do
    vim.lsp.config(name, server)
    vim.lsp.enable(name)
  end
end

-- ============================================================
-- SECTION 7: FORMATTING
-- conform.nvim setup and keymap
-- ============================================================
do
  -- [[ Formatting ]]
  vim.pack.add { gh 'stevearc/conform.nvim' }
  require('conform').setup {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- You can specify filetypes to autoformat on save here:
      -- <CUSTOM CHANGE> mirrors the keys of `formatters_by_ft` below; upstream ships
      -- this list empty, which would silently disable format-on-save entirely.
      -- `lua` has no conform entry on purpose -- it formats via the stylua LSP
      -- through `default_format_opts.lsp_format = 'fallback'`.
      local enabled_filetypes = {
        lua = true,
        python = true,
        markdown = true,
        json = true,
        html = true,
        yaml = true,
        sh = true,
        bash = true,
        zsh = true,
        terraform = true,
      }
      if enabled_filetypes[vim.bo[bufnr].filetype] then
        return { timeout_ms = 500 }
      else
        return nil
      end
    end,
    default_format_opts = {
      lsp_format = 'fallback', -- Use external formatters if configured below, otherwise use LSP formatting. Set to `false` to disable LSP formatting entirely.
    },
    -- You can also specify external formatters in here.
    -- <CUSTOM CHANGE> our formatter set. NOTE: no `lua` entry on purpose -- upstream runs
    -- stylua as an LSP formatter (`stylua = {}` in the `servers` table), and conform
    -- reaches it via `default_format_opts.lsp_format = 'fallback'`. Adding
    -- `lua = { 'stylua' }` here would format Lua buffers twice.
    formatters_by_ft = {
      python = { 'ruff_fix', 'ruff_format' },
      -- python = { 'ruff_organize_imports', 'ruff_format' }
      markdown = { 'injected', 'prettier' },
      json = { 'prettier' },
      html = { 'prettier' },
      yaml = { 'prettier' },
      sh = { 'shfmt' },
      bash = { 'shfmt' },
      zsh = { 'shfmt' },
      terraform = { 'terraform_fmt' },
    },
    formatters = {
      shfmt = { prepend_args = { '-i', '4' } }, -- <CUSTOM CHANGE>
    },
  }

  vim.keymap.set({ 'n', 'v' }, '<leader>f', function() require('conform').format { async = true } end, { desc = '[F]ormat buffer' })
end

-- ============================================================
-- SECTION 8: AUTOCOMPLETE & SNIPPETS
-- blink.cmp and luasnip setup
-- ============================================================
do
  -- [[ Snippet Engine ]]

  -- NOTE: You can also specify plugin using a version range for its git tag.
  --  See `:help vim.version.range()` for more info
  vim.pack.add { { src = gh 'L3MON4D3/LuaSnip', version = vim.version.range '2.*' } }
  require('luasnip').setup {}

  -- `friendly-snippets` contains a variety of premade snippets.
  --    See the README about individual language/framework/plugin snippets:
  --    https://github.com/rafamadriz/friendly-snippets
  -- <CUSTOM CHANGE> enabled (upstream ships this commented out)
  vim.pack.add { gh 'rafamadriz/friendly-snippets' }
  require('luasnip.loaders.from_vscode').lazy_load()

  -- [[ Autocomplete Engine ]]
  vim.pack.add { { src = gh 'saghen/blink.cmp', version = vim.version.range '1.*' } }

  -- <CUSTOM CHANGE> completion sources referenced by `sources.providers` below.
  -- blink.compat proxies the two nvim-cmp sources (dotenv, sql); it must be on the
  -- runtimepath before those providers are resolved.
  vim.pack.add {
    { src = gh 'saghen/blink.compat', version = vim.version.range '2.*' },
    gh 'moyiz/blink-emoji.nvim',
    -- gh 'bydlw98/blink-cmp-env',
    gh 'SergioRibera/cmp-dotenv',
    gh 'ray-x/cmp-sql',
  }
  -- lazy.nvim called this via `opts = {}`; vim.pack needs it explicitly. It registers the
  -- BlinkCmpAccept/Show/Hide -> nvim-cmp event bridge that compat sources rely on.
  require('blink.compat').setup {}

  require('blink.cmp').setup {
    keymap = {
      -- 'default' (recommended) for mappings similar to built-in completions
      --   <c-y> to accept ([y]es) the completion.
      --    This will auto-import if your LSP supports it.
      --    This will expand snippets if the LSP sent a snippet.
      -- 'super-tab' for tab to accept
      -- 'enter' for enter to accept
      -- 'none' for no mappings
      --
      -- For an understanding of why the 'default' preset is recommended,
      -- you will need to read `:help ins-completion`
      --
      -- No, but seriously. Please read `:help ins-completion`, it is really good!
      --
      -- All presets have the following mappings:
      -- <tab>/<s-tab>: move to right/left of your snippet expansion
      -- <c-space>: Open menu or open docs if already open
      -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
      -- <c-e>: Hide menu
      -- <c-k>: Toggle signature help
      --
      -- See `:help blink-cmp-config-keymap` for defining your own keymap
      preset = 'default',

      -- <CUSTOM CHANGE>
      ['<A-CR>'] = {
        function(cmp) cmp.show() end,
      },

      -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
      --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
    },

    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = 'mono',
    },

    completion = {
      -- By default, you may press `<c-space>` to show the documentation.
      -- Optionally, set `auto_show = true` to show the documentation after a delay.
      -- <CUSTOM CHANGE> auto-show docs + rounded borders
      documentation = { auto_show = true, auto_show_delay_ms = 500, window = { border = 'rounded' } },
      menu = { border = 'rounded' },
    },

    -- <CUSTOM CHANGE> emoji/dotenv sources by default; dadbod+sql for SQL buffers
    sources = {
      -- default = { 'lsp', 'path', 'snippets' },
      default = { 'lsp', 'path', 'emoji', 'dotenv' },
      per_filetype = {
        -- NOTE: `dadbod` resolves to vim-dadbod-completion, which arrives in Phase 3
        sql = { 'snippets', 'dadbod', 'sql' },
      },
      providers = {
        dadbod = { name = 'Dadbod', module = 'vim_dadbod_completion.blink' },
        emoji = {
          module = 'blink-emoji',
          name = 'Emoji',
          score_offset = 15, -- Tune by preference
          opts = { insert = true }, -- Insert emoji (default) or complete its name
          should_show_items = function()
            return vim.tbl_contains(
              -- Enable emoji completion only for git commits and markdown.
              -- By default, enabled for all file-types.
              { 'gitcommit', 'markdown', 'python' },
              vim.o.filetype
            )
          end,
        },
        -- env = {
        --   name = 'Env',
        --   module = 'blink-cmp-env',
        --   --- @type blink-cmp-env.Options
        --   opts = {
        --     -- item_kind = require('blink.cmp.types').CompletionItemKind.Variable,
        --     show_braces = false,
        --     show_documentation_window = true,
        --   },
        -- },
        dotenv = {
          name = 'dotenv',
          module = 'blink.compat.source',

          -- all blink.cmp source config options work as normal:
          score_offset = -3,

          -- this table is passed directly to the proxied completion source
          -- as the `option` field in nvim-cmp's source config
          --
          -- this is NOT the same as the opts in a plugin's lazy.nvim spec
          opts = { path = '.' },
        },
        sql = {
          name = 'sql',
          module = 'blink.compat.source',

          -- all blink.cmp source config options work as normal:
          score_offset = -3,

          -- this table is passed directly to the proxied completion source
          -- as the `option` field in nvim-cmp's source config
          --
          -- this is NOT the same as the opts in a plugin's lazy.nvim spec
          opts = {},
        },
      },
    },

    snippets = { preset = 'luasnip' },

    -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
    -- which automatically downloads a prebuilt binary when enabled.
    --
    -- By default, we use the Lua implementation instead, but you may enable
    -- the rust implementation via `'prefer_rust_with_warning'`
    --
    -- See `:help blink-cmp-config-fuzzy` for more information
    -- fuzzy = { implementation = 'lua' },
    fuzzy = { implementation = 'prefer_rust_with_warning' }, -- <CUSTOM CHANGE>

    -- Shows a signature help window while you type arguments for a function
    signature = { enabled = true, window = { border = 'rounded' } }, -- <CUSTOM CHANGE>
  }
end

-- ============================================================
-- SECTION 9: TREESITTER
-- Parser installation, syntax highlighting, folds, indentation
-- ============================================================
do
  -- [[ Configure Treesitter ]]
  --  Used to highlight, edit, and navigate code
  --
  --  See `:help nvim-treesitter-intro`

  -- <CUSTOM CHANGE> Register custom predicate for mise TOML injection queries.
  -- This was lazy.nvim's `init` hook; vim.pack has no equivalent, and the predicate
  -- is a core `vim.treesitter` API, so it just runs before the parsers are used.
  vim.treesitter.query.add_predicate('is-mise?', function(_, _, bufnr, _)
    local filepath = vim.api.nvim_buf_get_name(tonumber(bufnr) or 0)
    local filename = vim.fn.fnamemodify(filepath, ':t')
    return string.match(filename, '.*mise.*%.toml$') ~= nil
  end, { force = true, all = false })

  -- NOTE: You can also specify a branch or a specific commit
  vim.pack.add { { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' } }

  -- Ensure basic parsers are installed
  local parsers = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' }
  vim.list_extend(parsers, { 'python', 'dockerfile', 'sql', 'json', 'yaml', 'toml', 'kdl' }) -- <CUSTOM CHANGE>
  -- <CUSTOM CHANGE> limit parallel parser compilations to avoid freezing remote machines
  require('nvim-treesitter').install(parsers, { max_jobs = 2 })

  ---@param buf integer
  ---@param language string
  local function treesitter_try_attach(buf, language)
    -- Check if a parser exists and load it
    if not vim.treesitter.language.add(language) then return end
    -- Enable syntax highlighting and other treesitter features
    vim.treesitter.start(buf, language)

    -- Enable treesitter based folds
    -- For more info on folds see `:help folds`
    -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    -- vim.wo.foldmethod = 'expr'

    -- Check if treesitter indentation is available for this language, and if so enable it
    -- in case there is no indent query, the indentexpr will fallback to the vim's built in one
    local has_indent_query = vim.treesitter.query.get(language, 'indents') ~= nil

    -- Enable treesitter based indentation
    if has_indent_query then vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
  end

  local available_parsers = require('nvim-treesitter').get_available()
  vim.api.nvim_create_autocmd('FileType', {
    callback = function(args)
      local buf, filetype = args.buf, args.match

      local language = vim.treesitter.language.get_lang(filetype)
      if not language then return end

      local installed_parsers = require('nvim-treesitter').get_installed 'parsers'

      if vim.tbl_contains(installed_parsers, language) then
        -- Enable the parser if it is already installed
        treesitter_try_attach(buf, language)
      elseif vim.tbl_contains(available_parsers, language) then
        -- If a parser is available in `nvim-treesitter`, auto-install it and enable it after the installation is done
        require('nvim-treesitter').install(language):await(function() treesitter_try_attach(buf, language) end)
      else
        -- Try to enable treesitter features in case the parser exists but is not available from `nvim-treesitter`
        treesitter_try_attach(buf, language)
      end
    end,
  })

  -- <CUSTOM CHANGE> incremental selection using native vim.treesitter API
  -- (replaces removed nvim-treesitter.configs incremental_selection module)
  local selection_stack = {}

  local function reset_stack(buf) selection_stack[buf] = nil end

  vim.api.nvim_create_autocmd('ModeChanged', {
    pattern = '*:n',
    callback = function() reset_stack(vim.api.nvim_get_current_buf()) end,
  })

  -- Init / expand selection: <A-i>
  vim.keymap.set('n', '<A-i>', function()
    local buf = vim.api.nvim_get_current_buf()
    local node = vim.treesitter.get_node()
    if not node then return end
    selection_stack[buf] = { node }
    local sr, sc, er, ec = node:range()
    vim.fn.setpos("'<", { buf, sr + 1, sc + 1, 0 })
    vim.fn.setpos("'>", { buf, er + 1, ec, 0 })
    vim.cmd 'normal! gv'
  end, { desc = 'Init treesitter selection' })

  vim.keymap.set('v', '<A-i>', function()
    local buf = vim.api.nvim_get_current_buf()
    local stack = selection_stack[buf]
    if not stack or #stack == 0 then return end
    local current = stack[#stack]
    local parent = current:parent()
    if not parent then return end
    table.insert(stack, parent)
    local sr, sc, er, ec = parent:range()
    vim.fn.setpos("'<", { buf, sr + 1, sc + 1, 0 })
    vim.fn.setpos("'>", { buf, er + 1, ec, 0 })
    vim.cmd 'normal! gv'
  end, { desc = 'Expand treesitter selection' })

  -- Shrink selection: <A-d>
  vim.keymap.set('v', '<A-d>', function()
    local buf = vim.api.nvim_get_current_buf()
    local stack = selection_stack[buf]
    if not stack or #stack <= 1 then return end
    table.remove(stack)
    local node = stack[#stack]
    local sr, sc, er, ec = node:range()
    vim.fn.setpos("'<", { buf, sr + 1, sc + 1, 0 })
    vim.fn.setpos("'>", { buf, er + 1, ec, 0 })
    vim.cmd 'normal! gv'
  end, { desc = 'Shrink treesitter selection' })

  -- Expand to scope (named parent): <A-s>
  vim.keymap.set('v', '<A-s>', function()
    local buf = vim.api.nvim_get_current_buf()
    local stack = selection_stack[buf]
    if not stack or #stack == 0 then return end
    local current = stack[#stack]
    local parent = current:parent()
    while parent and not parent:named() do
      parent = parent:parent()
    end
    if not parent then return end
    table.insert(stack, parent)
    local sr, sc, er, ec = parent:range()
    vim.fn.setpos("'<", { buf, sr + 1, sc + 1, 0 })
    vim.fn.setpos("'>", { buf, er + 1, ec, 0 })
    vim.cmd 'normal! gv'
  end, { desc = 'Expand treesitter selection to scope' })
end

-- ============================================================
-- SECTION 10: OPTIONAL EXAMPLES / NEXT STEPS
-- kickstart.plugins.* examples
-- ============================================================
do
  -- The following comments only work if you have downloaded the kickstart repo, not just copy pasted the
  -- init.lua. If you want these files, they are in the repository, so you can just download them and
  -- place them in the correct locations.

  -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
  --
  --  Here are some example plugins that I've included in the Kickstart repository.
  --  Uncomment any of the lines below to enable them (you will need to restart nvim).
  --
  -- require 'kickstart.plugins.debug'
  -- <CUSTOM CHANGE> these five are enabled
  require 'kickstart.plugins.indent_line'
  require 'kickstart.plugins.lint'
  require 'kickstart.plugins.autopairs'
  require 'kickstart.plugins.neo-tree'
  require 'kickstart.plugins.gitsigns' -- adds gitsigns recommended keymaps

  -- NOTE: You can add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --
  --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  require 'custom.plugins' -- <CUSTOM CHANGE>
end

require('custom.doppler').setup() -- <CUSTOM CHANGE>

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
