-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

-- <CUSTOM CHANGE> Upstream ships an auto-loader that iterates this directory with
-- `vim.fs.dir`. That iteration order is filesystem order, not sorted, so it cannot
-- express load order -- and `vim.pack.add` IS order-sensitive (there is no dependency
-- graph, unlike lazy.nvim). See nvim-lua/kickstart.nvim#2038.
--
-- We therefore require our modules explicitly, in dependency order.
--
-- <CUSTOM CHANGE> Each module is loaded through `pcall` so a failure is isolated to
-- that module instead of aborting every module after it.
--
-- This matters because `vim.pack` can report a plugin as installed while leaving its
-- working tree empty (observed once: `.git` present, HEAD on the wrong branch, no
-- files). A bare `require` of such a plugin then throws an ordinary Lua error, and
-- without this guard every later module silently never runs -- the symptom is a
-- half-configured editor rather than an obvious failure.
--
-- Note this is NOT the same as nvim-lua/neovim#34786 (`vim.pack.add` stopping on a
-- package *load* error), which was fixed upstream in neovim#34787 -- there vim.pack
-- itself raises; here it reports success. Upstream will not emit failure events for
-- this case either (neovim#37619, closed NOT_PLANNED), so guarding here is the only
-- option available to us.
---@param mod string
---@return boolean ok
local function load(mod)
  local ok, err = pcall(require, mod)
  if not ok then
    -- Deferred: during startup a notification can be swallowed, and if `ui` itself is
    -- the module that failed then nvim-notify/noice are not available yet.
    vim.schedule(function() vim.notify(('custom.plugins: %s failed to load\n%s'):format(mod, err), vim.log.levels.ERROR) end)
  end
  return ok
end

load 'custom.plugins.ui'
load 'custom.plugins.editor'
load 'custom.plugins.git'
load 'custom.plugins.python'
load 'custom.plugins.misc'
