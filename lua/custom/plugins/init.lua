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
require 'custom.plugins.ui'
require 'custom.plugins.editor'
require 'custom.plugins.git'
