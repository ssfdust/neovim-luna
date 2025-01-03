-----------------------------------------------------------
-- Original popup completion menu framework library
-----------------------------------------------------------

-- Plugin Name: pum.vim
-- url: https://github.com/Shougo/pum.vim
-- Original: https://github.com/Shougo/shougo-s-github/blob/master/vim/rc/ddc.toml
--
-- lua_source {{{
local fn = vim.fn

local pum_set_option = fn["pum#set_option"]

pum_set_option({
    auto_confirm_time = 0,
    auto_select = false,
    border = 'none',
    commit_characters = {'.'},
    highlight_scrollbar = 'None',
    insert_preview = true,
    max_width = 80,
    offset_cmdcol = 0,
    padding = false,
    preview = false,
    preview_width = 80,
    reversed = false,
    use_setline = false,
})

-- local pum_set_local_option = fn["pum#set_local_option"]
-- pum_set_local_option('c', { horizontal_menu = false })

-- NOTE: For horizontal_menu
pum_set_option({
    follow_cursor = false,
    horizontal_menu = false,
    max_horizontal_items = 2,
    max_height = 7,
})

-- }}}
