-- Add indentation guides even on blank lines

-- Enable `lukas-reineke/indent-blankline.nvim`
-- See `:help ibl`
vim.pack.add { 'https://github.com/lukas-reineke/indent-blankline.nvim' }
require('ibl').setup {
  -- Delete the line below for a rather straight line
  indent = { char = '|' }, -- <CUSTOM CHANGE>
}
