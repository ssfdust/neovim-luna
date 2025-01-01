-- lua_source {{{
-----------------------------------------------------------
-- lualine configuration file
-----------------------------------------------------------

-- Plugin: barbar.nvim
-- url: https://github.com/romgrk/barbar.nvim
vim.g.barbar_auto_setup = false

require("barbar").setup {
    icons = {
        filetype = { enabled = false, custom_colors = true },
        inactive = { separator = { left = '', right = '' } },
        separator = { left = '', right = '' },
        separator_at_end = false,
        preset = 'slanted',
    }
}


-- }}}
