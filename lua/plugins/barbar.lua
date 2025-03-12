-----------------------------------------------------------
-- lualine configuration file
-----------------------------------------------------------

-- Plugin: barbar.nvim
-- url: https://github.com/romgrk/barbar.nvim

-- lua_add {{{
local set_keymap = vim.keymap.set             -- Set key map
local key_map_opts = { noremap = true, silent = true }

-- Move to previous/next
set_keymap('n', '<A-,>', '<Cmd>BufferPrevious<CR>', key_map_opts)
set_keymap('n', '<A-.>', '<Cmd>BufferNext<CR>', key_map_opts)

-- Re-order to previous/next
set_keymap('n', '<A-<>', '<Cmd>BufferMovePrevious<CR>', key_map_opts)
set_keymap('n', '<A->>', '<Cmd>BufferMoveNext<CR>', key_map_opts)

-- Goto buffer in position...
set_keymap('n', '<A-1>', '<Cmd>BufferGoto 1<CR>', key_map_opts)
set_keymap('n', '<A-2>', '<Cmd>BufferGoto 2<CR>', key_map_opts)
set_keymap('n', '<A-3>', '<Cmd>BufferGoto 3<CR>', key_map_opts)
set_keymap('n', '<A-4>', '<Cmd>BufferGoto 4<CR>', key_map_opts)
set_keymap('n', '<A-5>', '<Cmd>BufferGoto 5<CR>', key_map_opts)
set_keymap('n', '<A-6>', '<Cmd>BufferGoto 6<CR>', key_map_opts)
set_keymap('n', '<A-7>', '<Cmd>BufferGoto 7<CR>', key_map_opts)
set_keymap('n', '<A-8>', '<Cmd>BufferGoto 8<CR>', key_map_opts)
set_keymap('n', '<A-9>', '<Cmd>BufferGoto 9<CR>', key_map_opts)
set_keymap('n', '<A-0>', '<Cmd>BufferLast<CR>', key_map_opts)

-- Pin/unpin buffer
set_keymap('n', '<A-p>', '<Cmd>BufferPin<CR>', key_map_opts)

-- Close buffer
set_keymap('n', '<A-c>', '<Cmd>BufferClose<CR>', key_map_opts)

-- Magic buffer-picking mode
set_keymap('n', '<C-p>',   '<Cmd>BufferPick<CR>', key_map_opts)
set_keymap('n', '<C-s-p>', '<Cmd>BufferPickDelete<CR>', key_map_opts)

-- Sort automatically by...
set_keymap('n', '<Space>bb', '<Cmd>BufferOrderByBufferNumber<CR>', key_map_opts)
set_keymap('n', '<Space>bn', '<Cmd>BufferOrderByName<CR>', key_map_opts)
set_keymap('n', '<Space>bd', '<Cmd>BufferOrderByDirectory<CR>', key_map_opts)
set_keymap('n', '<Space>bl', '<Cmd>BufferOrderByLanguage<CR>', key_map_opts)
set_keymap('n', '<Space>bw', '<Cmd>BufferOrderByWindowNumber<CR>', key_map_opts)
-- }}}

-- lua_source {{{
vim.g.barbar_auto_setup = false

require("barbar").setup {
    icons = {
        filetype = { enabled = true, custom_colors = true },
        inactive = { separator = { left = '', right = '' } },
        separator = { left = '', right = '' },
        separator_at_end = false,
        preset = 'slanted',
    }
}


-- }}}
