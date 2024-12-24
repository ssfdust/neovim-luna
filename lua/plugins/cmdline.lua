-- lua_add {{{
-----------------------------------------------------------
-- Deol configuration
-----------------------------------------------------------

-- Plugin Name: cmdline
-- url: https://github.com/Shougo/cmdline.nvim
local set_keymap = vim.keymap.set             -- Set key map
local key_map_opts = { noremap = true, silent = true }

set_keymap('c', '<CR>',
    function()
        local cmdline_disable = vim.fn['cmdline#disable']
        cmdline_disable()
    end,
    key_map_opts
)

-- }}}

-- lua_source {{{
local cmdline_set_option = vim.fn['cmdline#set_option']
cmdline_set_option({
    highlight_cursor = 'CmdlineCursor',
    highlight_window = 'None',
})
-- }}}
