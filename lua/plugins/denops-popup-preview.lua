-----------------------------------------------------------
--  Show completion documentation 
-----------------------------------------------------------

-- Plugin Name: denops-popup-preview.vim
-- url: https://github.com/matsui54/denops-popup-preview.vim

-- lua_add {{{
local fn = vim.fn
local set_buf_keymap = vim.keymap.set
local key_map_opts = { noremap = true, expr = true }

set_buf_keymap("i", "<C-f>", function() return fn['popup_preview#scroll'](4) end, key_map_opts)
set_buf_keymap("i", "<C-b>", function() return fn['popup_preview#scroll'](-4) end, key_map_opts)
-- }}}

-- lua_source {{{
vim.fn['popup_preview#enable']()
-- }}}
