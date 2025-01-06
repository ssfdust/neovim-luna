-----------------------------------------------------------
--  Show completion documentation 
-----------------------------------------------------------

-- Plugin Name: denops-popup-preview.vim
-- url: https://github.com/matsui54/denops-popup-preview.vim

-- lua_add {{{
local fn = vim.fn

local autocmd = vim.api.nvim_create_autocmd

local set_keymap = vim.keymap.set
local key_map_opts = {
    noremap = true,
    expr = true,
    silent = true,
    buffer = true,
    -- the `popup_preview#scroll` returns the internal codes already, it results
    -- in unexpected behavior when this option is true.
    -- this option is true on default when `expr` is true.
    replace_keycodes = false
}

-- Create the scroll keymap only for attached buffer.
autocmd(
    "LspAttach",
    {
        callback = function()
            set_keymap("i", "<C-f>",
                function()
                    return fn['popup_preview#scroll'](6)
                end,
                key_map_opts
            )
            set_keymap("i", "<C-b>",
                function()
                    return fn['popup_preview#scroll'](-6)
                end,
                key_map_opts
            )
        end
    }
)
-- }}}

-- lua_source {{{
vim.fn['popup_preview#enable']()
-- }}}
