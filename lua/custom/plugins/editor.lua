-- Editor / navigation: movement, terminals, folds, file manager, multi-cursor
--
-- NOTE (vim.pack): plugins load in the order they are added, and each needs an
-- explicit `setup()` -- lazy.nvim's `dependencies` and `opts` do not exist here.

local gh = function(repo) return 'https://github.com/' .. repo end

-- <CUSTOM CHANGE> was lazy.nvim's `init` on yazi.nvim: must run before netrw is
-- sourced, which happens after init.lua finishes.
-- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
-- vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.pack.add {
  gh 'christoomey/vim-tmux-navigator',
  gh 'tpope/vim-surround',
  { src = gh 'mg979/vim-visual-multi', version = 'master' },
}
-- vim.g.VM_leader = '\t'

-- Sticky context header. nvim-treesitter is added in init.lua SECTION 9.
vim.pack.add { gh 'nvim-treesitter/nvim-treesitter-context' }
require('treesitter-context').setup { multiline_threshold = 1 }

-- Floating terminal
vim.pack.add { { src = gh 'akinsho/toggleterm.nvim', version = vim.version.range '*' } }
require('toggleterm').setup {
  size = 20, -- float size in lines (or function)
  open_mapping = [[<A-t>]], -- your toggle key
  direction = 'float', -- float | split | tab
  float_opts = { -- only for float
    border = 'curved', -- single|double|rounded|curved|none
    winblend = 0, -- transparency
  },
  start_in_insert = true, -- auto-enter insert
  persist_size = true, -- remember last size
}

-- LSP preview windows (gpd/gpt/gpi/gpD/gpr/gP via default_mappings)
vim.pack.add { gh 'rmagatti/goto-preview' }
require('goto-preview').setup {
  width = 140,
  height = 40,
  border = { '↖', '─', '┐', '│', '┘', '─', '└', '│' },
  default_mappings = true,
  references = {
    telescope = require('telescope.themes').get_dropdown { hide_preview = false },
  },
  focus_on_open = true,
  force_close = true,
  bufhidden = 'wipe',
  stack_floating_preview_windows = true,
  preview_window_title = { enable = true, position = 'left' },
}

-- Harpoon (plenary comes from the telescope block in init.lua SECTION 5)
vim.pack.add { { src = gh 'ThePrimeagen/harpoon', version = 'harpoon2' } }
local harpoon = require 'harpoon'

-- REQUIRED
harpoon:setup {}
-- REQUIRED

vim.keymap.set('n', '<leader>ha', function() harpoon:list():add() end, { desc = '[A]dd buffer to harpoon list' })
vim.keymap.set('n', '<A-h>', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

-- vim.keymap.set('n', '<C-h>', function() harpoon:list():select(1) end)
-- vim.keymap.set('n', '<C-t>', function() harpoon:list():select(2) end)
-- vim.keymap.set('n', '<C-n>', function() harpoon:list():select(3) end)
-- vim.keymap.set('n', '<C-s>', function() harpoon:list():select(4) end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set('n', '<A-p>', function() harpoon:list():prev() end)
vim.keymap.set('n', '<A-n>', function() harpoon:list():next() end)

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

vim.keymap.set('n', '<leader>sp', function() toggle_telescope(harpoon:list()) end, { desc = '[S]earch in har[p]oon' })

-- Docstring creation
vim.pack.add { gh 'danymat/neogen' }
require('neogen').setup {}
vim.keymap.set('n', '<leader>dg', function() require('neogen').generate() end, { desc = 'Generate Docstring' })

-- Folds. promise-async must be added before nvim-ufo.
vim.pack.add {
  gh 'kevinhwang91/promise-async',
  gh 'kevinhwang91/nvim-ufo',
}
vim.opt.foldcolumn = '1' -- '0' is not bad
vim.opt.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true

-- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
vim.keymap.set('n', 'z<space>', function()
  if vim.opt.foldlevel:get() == 1 then
    vim.opt.foldlevel = 99
  else
    vim.opt.foldlevel = 1
  end
end, { noremap = true, silent = true, desc = 'Set fold level to 1' })
vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
vim.keymap.set('n', 'zK', function()
  local winid = require('ufo').peekFoldedLinesUnderCursor()
  if not winid then vim.lsp.buf.hover() end
end, { desc = 'Peek fold' })

require('ufo').setup {
  provider_selector = function(bufnr, filetype, buftype) return { 'lsp', 'indent' } end,
}

-- Jump motions
vim.pack.add { gh 'folke/flash.nvim' }
require('flash').setup {}
-- stylua: ignore start
vim.keymap.set({ 'n', 'x', 'o' }, 's',     function() require('flash').jump() end,              { desc = 'Flash' })
vim.keymap.set({ 'n', 'x', 'o' }, 'S',     function() require('flash').treesitter() end,        { desc = 'Flash Treesitter' })
vim.keymap.set('o',               'r',     function() require('flash').remote() end,            { desc = 'Remote Flash' })
vim.keymap.set({ 'o', 'x' },      'R',     function() require('flash').treesitter_search() end, { desc = 'Treesitter Search' })
vim.keymap.set('c',               '<c-s>', function() require('flash').toggle() end,            { desc = 'Toggle Flash Search' })
-- stylua: ignore end

-- Disable expensive features in very large files
vim.pack.add { gh 'LunarVim/bigfile.nvim' }
require('bigfile').setup {
  filesize = 2, -- size of the file in MiB, the plugin round file sizes to the closest MiB
}

-- File manager. snacks.nvim is a hard dependency of yazi.nvim.
vim.pack.add {
  gh 'folke/snacks.nvim',
  gh 'mikavilpas/yazi.nvim',
}
require('yazi').setup {
  -- if you want to open yazi instead of netrw, see below for more info
  open_for_directories = true,
  keymaps = {
    show_help = '<f1>',
  },
}
vim.keymap.set({ 'n', 'v' }, '<leader>-', '<cmd>Yazi<cr>', { desc = 'Open yazi at the current file' })
vim.keymap.set('n', '<leader>cw', '<cmd>Yazi cwd<cr>', { desc = "Open the file manager in nvim's working directory" })
vim.keymap.set('n', '<c-up>', '<cmd>Yazi toggle<cr>', { desc = 'Resume the last yazi session' })
