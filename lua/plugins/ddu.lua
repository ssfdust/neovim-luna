-- lua_add {{{
-----------------------------------------------------------
-- Ddu configuration file
-----------------------------------------------------------

-- Plugin: ddu.vim
-- url: https://github.com/Shougo/ddu.vim
local set_keymap = vim.keymap.set             -- Set key map
set_keymap(
    'n',
    ' ff',
    function()
        local ddu_start = vim.fn['ddu#start']
        ddu_start({
            name = 'files',
            ui = 'ff',
            sources = {
                {
                    name = 'filer',
                }
            },
            uiParams = {
                ff = {
                    startFilter = true,
                    previewFloating = true,
                    split = 'floating'
                }
            }
        })
    end,
    { noremap = true, silent = true })
-- }}}


-- lua_source {{{
local augroup = vim.api.nvim_create_augroup   -- Create/get autocommand group
augroup('DduUserGrp', { clear = true })
local ddu_load_config = vim.fn["ddu#custom#load_config"]
ddu_load_config(vim.fn.expand("$BASE_DIR/dpp_ext/ddu/ddu.ts"))
-- }}}
