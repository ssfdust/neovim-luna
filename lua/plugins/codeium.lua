-- lua_add {{{
-----------------------------------------------------------
-- Codeium plugin configuration file
-----------------------------------------------------------
--
-- Plugin: codeium.vim
-- url: https://github.com/Exafunction/codeium.vim

local g = vim.g                             -- Global variables
local fn = vim.fn                           -- Vim built-in functions
local set_keymap = vim.keymap.set           -- Set key map

g.codeium_disable_bindings = 1
g.codeium_manual = true

set_keymap('i', '<C-l>', function () return fn['codeium#Accept']() end, { expr = true, silent = true })
set_keymap('i', '<C-\\>', function() return fn['codeium#CycleOrComplete']() end, { expr = true, silent = true })
set_keymap('i', '<C-_>', function() return fn['codeium#Clear']() end, { expr = true, silent = true })
-- }}}
