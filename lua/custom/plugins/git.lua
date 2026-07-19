-- Git: neogit, fugitive, worktrees
--
-- NOTE (vim.pack): plugins load in the order they are added, and each needs an
-- explicit `setup()` -- lazy.nvim's `dependencies` and `opts` do not exist here.
-- This module must load AFTER `custom.plugins.editor` (the worktree SWITCH hook
-- uses yazi) and after kickstart's neo-tree module.

local gh = function(repo) return 'https://github.com/' .. repo end

-- diffview is a neogit dependency; plenary/telescope come from init.lua SECTION 5.
vim.pack.add {
  gh 'sindrets/diffview.nvim',
  gh 'NeogitOrg/neogit',
}
require('neogit').setup {}

vim.keymap.set('n', '<leader>gP', '<cmd>Neogit push<CR>', { desc = 'git push' })
vim.keymap.set('n', '<leader>gb', '<cmd>Telescope git_branches<CR>', { desc = 'git branch with telescope' })
vim.keymap.set('n', '<leader>gc', '<cmd>Neogit commit<CR>', { desc = 'git commit' })
vim.keymap.set('n', '<leader>gf', '<cmd>Neogit kind=floating<CR>', { desc = 'git status in floating mode' })
vim.keymap.set('n', '<leader>gl', '<cmd>Neogit log<CR>', { desc = 'git log' })
vim.keymap.set('n', '<leader>gp', '<cmd>Neogit pull<CR>', { desc = 'git pull' })
vim.keymap.set('n', '<leader>gs', '<cmd>Neogit<CR>', { desc = 'git status' })

vim.pack.add { gh 'tpope/vim-fugitive' }
vim.keymap.set('n', '<leader>gd', '<CMD>Gvdiffsplit!<CR>', { desc = 'Gvdiffsplit' })

-- Worktrees
vim.pack.add { { src = gh 'polarmutex/git-worktree.nvim', version = vim.version.range '^2' } }

-- 1) Default options via vim.g
vim.g.git_worktree = {
  change_directory_command = 'cd', -- or "tcd"
  update_on_change = true,
  update_on_change_command = 'e .', -- open root in new tree
  clearjumps_on_change = true,
  autopush = false,
  confirm_telescope_deletions = true,
}

-- 2) Pull in the hooks API (hyphens here!)
local gw = require 'git-worktree'
local Hooks = require 'git-worktree.hooks'
local cfg = require 'git-worktree.config'
local Job = require 'plenary.job'

-- Fix: strip remote prefix so plugin doesn't create "local/origin/<branch>" names
local original_create = gw.create_worktree
gw.create_worktree = function(path, branch, upstream)
  if branch and not upstream then
    local remote_prefix, stripped = branch:match '^(%w+)/(.+)$'
    if stripped then
      local remotes = vim.fn.systemlist 'git remote'
      for _, remote in ipairs(remotes) do
        if remote == remote_prefix then
          upstream = branch
          branch = stripped
          break
        end
      end
    end
  end
  return original_create(path, branch, upstream)
end

local builtin = Hooks.builtins
local neo_command = require 'neo-tree.command'
local has_yazi, yazi = pcall(require, 'yazi')

-- SWITCH: if the buffer exists in the new tree, reload it
-- Hooks.register(Hooks.type.SWITCH, Hooks.builtins.update_current_buffer_on_switch)
Hooks.register(Hooks.type.SWITCH, function(new_path, prev_path)
  -- -- 0) Change Neovim's cwd to the new worktree
  -- vim.cmd('cd ' .. vim.fn.fnameescape(new_path))

  -- 1) Neo-Tree: reveal the new cwd
  --    We close any existing Neo-Tree and then reopen it in `new_path`.
  --    If Neo-Tree isn't installed/loaded, pcall will skip it silently.
  pcall(function()
    neo_command.execute { action = 'close' }
    neo_command.execute {
      action = 'reveal',
      dir = new_path,
      position = 'current', -- or "left", etc., depending on your layout
    }
  end)

  -- 2) Yazi: toggle off & on so it rebinds to the new buffer
  if has_yazi then
    -- close any existing yazi window (no-op if none)
    pcall(yazi.close)
    -- reopen yazi in the new working directory
    pcall(function()
      -- second arg is the directory to open in
      yazi.yazi(nil, new_path)
    end)
  end

  -- 3) Finally, update the current buffer if it exists in new tree
  builtin.update_current_buffer_on_switch(new_path, prev_path)
end)

-- DELETE: run the update_on_change_command (open root)
Hooks.register(Hooks.type.DELETE, function() vim.cmd(cfg.update_on_change_command) end)

-- CREATE: check & set `remote.origin.fetch` in the new worktree
Hooks.register(Hooks.type.CREATE, function(path, metadata)
  Job:new({
    command = 'git',
    args = { 'config', '--get', 'remote.origin.fetch' },
    cwd = path,
    on_exit = function(job)
      local cur = table.concat(job:result(), '\n')
      if cur ~= '+refs/heads/*:refs/remotes/origin/*' then
        Job:new({
          command = 'git',
          args = {
            'config',
            'remote.origin.fetch',
            '+refs/heads/*:refs/remotes/origin/*',
          },
          cwd = path,
          on_exit = function(j2)
            if j2.code == 0 then
              vim.notify('✔️ remote.origin.fetch configured', vim.log.levels.INFO)
            else
              vim.notify('❌ failed to configure fetch spec', vim.log.levels.ERROR)
            end
          end,
        }):start()
      else
        vim.notify('remote.origin.fetch already correct', vim.log.levels.DEBUG)
      end
    end,
  }):start()
end)

-- 3) Telescope extension (the extension name stays underscore)
require('telescope').load_extension 'git_worktree'

-- 4) Keymaps
vim.keymap.set(
  'n',
  '<Leader>gW',
  function() require('telescope').extensions.git_worktree.create_git_worktree() end,
  { desc = 'Create a new worktree and configure fetch' }
)

vim.keymap.set('n', '<Leader>gw', function() require('telescope').extensions.git_worktree.git_worktree() end, { desc = 'List & switch/delete git worktrees' })
