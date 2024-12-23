-- lua_source {{{
-----------------------------------------------------------
-- Ddu UI configuration file
-----------------------------------------------------------

-- Plugin: ddu-ui-ff
-- url: https://github.com/Shougo/ddu-ui-ff

local augroup = vim.api.nvim_create_augroup   -- Create/get autocommand group
augroup('DduFFUserGrp', { clear = true })

local autocmd = vim.api.nvim_create_autocmd   -- Create autocommand
autocmd(
    {"TabEnter", "WinEnter", "CursorHold", "FocusGained"},
    {
        pattern = {"*"},
        group = "DduFFUserGrp",
        callback = function()
            local ddu_ui_do_action = vim.fn["ddu#ui#do_action"]
            ddu_ui_do_action('checkItems')
        end
    }
)
-- neovim won't call ftplugin scripts in dpp base directory, we have to source
-- it manually.
-- source: https://github.com/neovim/neovim/issues/12951
autocmd(
    "FileType",
    {
        pattern = "ddu-ff",
        group = "DduFFUserGrp",
        callback = function()
            vim.api.nvim_command('runtime! ftplugin/ddu-ff.vim')
        end
    }
)
-- }}}

-- lua_ddu-ff {{{
vim.b.aaa = '1111'
-- }}}
