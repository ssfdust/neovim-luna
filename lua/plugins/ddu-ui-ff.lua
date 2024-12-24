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
    "User",
    {
        pattern = "Ddu:ui:ff:openFilterWindow",
        group = "DduFFUserGrp",
        callback = function()
            vim.opt.cursorline = true

            local ddu_ui_save_cmaps = vim.fn['ddu#ui#ff#save_cmaps']
            local set_keymap = vim.keymap.set             -- Set key map
            local key_map_opts = { noremap = true, silent = true, buffer = true }
            local ddu_ui_do_action = vim.fn["ddu#ui#do_action"]

            set_keymap('c', '<C-f>',
                function() 
                    ddu_ui_do_action('cursorNext', { loop = true })
                end,
                key_map_opts
            )
            set_keymap('c', '<C-b>',
                function() 
                    ddu_ui_do_action('cursorPrevious', { loop = true })
                end,
                key_map_opts
            )
                
            ddu_ui_save_cmaps({'<C-f>', '<C-b>'})
        end
    }
)
autocmd(
    "User",
    {
        pattern = "Ddu:ui:ff:closeFilterWindow",
        group = "DduFFUserGrp",
        callback = function()
            vim.opt.cursorline = false
            local ddu_ui_restore_cmaps = vim.fn['ddu#ui#ff#restore_cmaps']
            ddu_ui_restore_cmaps()
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
local set_keymap = vim.keymap.set             -- Set key map
local key_map_opts = { noremap = true, silent = true, buffer = true }
local ddu_ui_do_action = vim.fn["ddu#ui#do_action"]
local ddu_ui_multi_actions = vim.fn["ddu#ui#multi_actions"]

-- Subwindow Action
set_keymap("n", "i", function() ddu_ui_do_action('openFilterWindow') end, key_map_opts)
set_keymap("n", "<CR>", function() ddu_ui_do_action('itemAction') end, key_map_opts)
set_keymap("n", "<Space><Space>", function() ddu_ui_do_action('toggleSelectItem') end, key_map_opts)
set_keymap("n", "*", function() ddu_ui_do_action('toggleAllItems') end, key_map_opts)
set_keymap("n", "a", function() ddu_ui_do_action('chooseAction') end, key_map_opts)
set_keymap("n", "A", function() ddu_ui_do_action('inputAction') end, key_map_opts)
set_keymap("n", "O", function() ddu_ui_do_action('collapseItem') end, key_map_opts)
set_keymap("n", "p", function() ddu_ui_do_action('previewPath') end, key_map_opts)
set_keymap("n", "P", function() ddu_ui_do_action('togglePreview') end, key_map_opts)
set_keymap("n", "q", function() ddu_ui_do_action('quit') end, key_map_opts)
set_keymap("n", "o",
    function()
        ddu_ui_do_action(
            'expandItem',
            {
                mode = 'toggle',
            }
        )
    end,
    key_map_opts
)
set_keymap("n", "r",
    function()
        ddu_ui_do_action(
            'itemAction',
            {
                name = 'quickfix',
            }
        )
    end,
    key_map_opts
)
set_keymap("n", "yy",
    function()
        ddu_ui_do_action(
            'itemAction',
            {
                name = 'yank',
            }
        )
    end,
    key_map_opts
)
set_keymap("n", "n",
    function()
        ddu_ui_do_action(
            'itemAction',
            {
                name = 'narrow',
            }
        )
    end,
    key_map_opts
)

-- Subwindow Cursor
set_keymap("n", "<C-j>", function() ddu_ui_do_action('cursorNext') end, key_map_opts)
set_keymap("n", "<C-k>", function() ddu_ui_do_action('cursorPrevious') end, key_map_opts)
set_keymap("n", "<C-n>",
    function()
        ddu_ui_multi_actions(
            {'cursorNext', 'itemAction'},
            'files'
        )
    end,
    key_map_opts
)
set_keymap("n", "<C-p>",
    function()
        ddu_ui_multi_actions(
            {'cursorPrevious', 'itemAction'},
            'files'
        )
    end,
    key_map_opts
)

-- Subwindow resize
set_keymap("n", ">",
    function()
        ddu_ui_multi_actions({
            {
                'updateOptions',
                {
                    uiParams = {
                        ff = {
                            winWidth = 80,
                        },
                    },
                },
            },
            {
                'redraw',
                {
                    method = 'uiRedraw',
                }
            },
        })
    end,
    key_map_opts
)
-- }}}
