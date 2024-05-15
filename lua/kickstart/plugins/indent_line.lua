return {
  { -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {
      -- Delete the line below for a rather straight line
      indent = { char = '|' }, --<CUSTOM CHANGE>
    },
  },
}
