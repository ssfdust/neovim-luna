-- lua_add {{{
-----------------------------------------------------------
-- Ddu UI configuration file
-----------------------------------------------------------

-- Plugin: ddu-ui-filer
-- url: https://github.com/Shougo/ddu-ui-filer
local set_keymap = vim.keymap.set             -- Set key map
local key_map_opts = { noremap = true, silent = true }

set_keymap(
    'n',
    '<Space>fl',
    function()
        local ddu_start = vim.fn['ddu#start']
        ddu_start({
            name = 'filer-' .. vim.fn.win_getid(),
            ui = 'filer',
            resume = true,
            sync = true,
            sources = {
                {
                    name = 'file',
                    options = {
                        path = vim.t.ddu_ui_filer_path or vim.fn.getcwd(),
                    }
                }
            },
        })
    end,
    key_map_opts    
)
set_keymap(
    'n',
    '<Space>fv',
    function()
        local ddu_start = vim.fn['ddu#start']
        ddu_start({
            name = 'filer-' .. vim.fn.win_getid(),
            ui = 'filer',
            resume = true,
            sync = true,
            sources = {
                {
                    name = 'file',
                    options = {
                        path = vim.t.ddu_ui_filer_path or vim.fn.getcwd(),
                    }
                }
            },
            uiParams = {
                filer = {
                    autoResize = true,
                    split = 'vertical',
                }
            }
        })
    end,
    key_map_opts    
)
-- }}}

-- lua_source {{{
local augroup = vim.api.nvim_create_augroup   -- Create/get autocommand group
augroup('DduFilerUserGrp', { clear = true })

local autocmd = vim.api.nvim_create_autocmd   -- Create autocommand
autocmd(
    {"TabEnter", "WinEnter", "CursorHold", "FocusGained"},
    {
        pattern = {"*"},
        group = "DduFilerUserGrp",
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
        pattern = "ddu-filer",
        group = "DduFilerUserGrp",
        callback = function()
            vim.api.nvim_command('runtime! ftplugin/ddu-filer.vim')
        end
    }
)
-- }}}

-- lua_ddu-filer {{{
local set_keymap = vim.keymap.set             -- Set key map
local key_map_opts = { noremap = true, buffer = true, silent = true }
local ddu_ui_do_action = vim.fn["ddu#ui#do_action"]
local ddu_ui_multi_actions = vim.fn["ddu#ui#multi_actions"]
local ddu_start = vim.fn["ddu#start"]
set_keymap("n", "<Space><Space>", function() ddu_ui_do_action('toggleSelectItem') end, key_map_opts)
set_keymap("n", "*", function() ddu_ui_do_action('toggleAllItems') end, key_map_opts)
set_keymap("n", "a", function() ddu_ui_do_action('chooseAction') end, key_map_opts)
set_keymap("n", "A", function() ddu_ui_do_action('inputAction') end, key_map_opts)
set_keymap("n", "P", function() ddu_ui_do_action('togglePreview') end, key_map_opts)
set_keymap("n", "T", function() ddu_ui_do_action('cursorTreeTop') end, key_map_opts)
set_keymap("n", "B", function() ddu_ui_do_action('cursorTreeBottom') end, key_map_opts)
set_keymap("n", "q", function() ddu_ui_do_action('quit') end, key_map_opts)
set_keymap("n", "gq", function() ddu_ui_do_action('quit') end, key_map_opts)
set_keymap("n", "<C-l>", function() ddu_ui_do_action('redraw') end, key_map_opts)
set_keymap("n", "o",
    function()
        ddu_ui_do_action(
            'expandItem',
            {
                mode = 'toggle',
                isGrouped = true,
                isInTree = false,
            }
        )
    end,
    key_map_opts
)
set_keymap("n", "O",
    function()
        ddu_ui_do_action(
            'expandItem',
            {
                maxLevel = -1,
            }
        )
    end,
    key_map_opts
)
set_keymap("n", "l",
    function()
        local ddu_ui_get_item = vim.fn['ddu#ui#get_item']
        local current = ddu_ui_get_item()
        local is_tree = current.isTree or false
        if is_tree then
            ddu_ui_do_action(
                'itemAction',
                {
                    name = 'narrow',
                }
            )
        else
            ddu_ui_do_action(
                'itemAction',
                {
                    name = 'open',
                }
            )
        end
    end,
    key_map_opts
)
set_keymap("n", "<CR>",
    function()
        local ddu_ui_get_item = vim.fn['ddu#ui#get_item']
        local current = ddu_ui_get_item()
        local is_tree = current.isTree or false
        if is_tree then
            ddu_ui_do_action(
                'itemAction',
                {
                    name = 'narrow',
                }
            )
        else
            ddu_ui_do_action(
                'itemAction',
                {
                    name = 'open',
                }
            )
        end
    end,
    key_map_opts
)
set_keymap("n", "c",
    function()
        ddu_ui_multi_actions({
            {'itemAction', { name = 'copy' }},
            {'clearSelectAllItems'},
        })
    end,
    key_map_opts
)
set_keymap("n", "t",
    function()
        ddu_ui_do_action(
            'itemAction',
            {
                name = 'open',
                params = {
                    command = 'tabedit'
                }
            }
        )
    end,
    key_map_opts
)
set_keymap("n", "D", function() ddu_ui_do_action('itemAction', { name = 'delete' }) end, key_map_opts)
set_keymap("n", "d", function() ddu_ui_do_action('itemAction', { name = 'trash' }) end, key_map_opts)
set_keymap("n", "m", function() ddu_ui_do_action('itemAction', { name = 'move' }) end, key_map_opts)
set_keymap("n", "r", function() ddu_ui_do_action('itemAction', { name = 'rename' }) end, key_map_opts)
set_keymap("n", "x", function() ddu_ui_do_action('itemAction', { name = 'executeSystem' }) end, key_map_opts)
set_keymap("n", "p", function() ddu_ui_do_action('itemAction', { name = 'paste' }) end, key_map_opts)
set_keymap("n", "K", function() ddu_ui_do_action('itemAction', { name = 'newDirectory' }) end, key_map_opts)
set_keymap("n", "N", function() ddu_ui_do_action('itemAction', { name = 'newFile' }) end, key_map_opts)
set_keymap("n", "L", function() ddu_ui_do_action('itemAction', { name = 'link' }) end, key_map_opts)
set_keymap("n", "u", function() ddu_ui_do_action('itemAction', { name = 'undo' }) end, key_map_opts)
set_keymap("n", "~",
    function()
        ddu_ui_do_action(
            'itemAction',
            {
                name = 'narrow',
                params = {
                    path = vim.fn.expand('~')
                }
            }
        )
    end,
    key_map_opts
)
set_keymap("n", "=",
    function()
        ddu_ui_do_action(
            'itemAction',
            {
                name = 'narrow',
                params = {
                    path = vim.fn.getcwd()
                }
            }
        )
    end,
    key_map_opts
)
set_keymap("n", "h",
    function()
        ddu_ui_do_action(
            'itemAction',
            {
                name = 'narrow',
                params = {
                    path = '..'
                }
            }
        )
    end,
    key_map_opts
)
set_keymap("n", "I",
    function()
        local input_path = vim.fn.input('cwd: ', vim.b.ddu_ui_filer_path, 'dir')
        local new_path = vim.fn.fnamemodify(input_path, ':p')
        ddu_ui_do_action(
            'itemAction',
            {
                name = 'narrow',
                params = {
                    path = new_path
                }
            }
        )
    end,
    key_map_opts
)
set_keymap("n", "M",
    function()
        local ddu_custom_get_current = vim.fn['ddu#custom#get_current']
        local current = ddu_custom_get_current(vim.b.ddu_ui_name)
        local ui_params = current.uiParams or {}
        local ui_params_filer = ui_params.filer or {}
        local previous_filer_filter = ui_params_filer.fileFilter or {}
        local input_file_filter = vim.fn.input(
            'fileFilter regexp: ',
            previous_filer_filter
        )
        ddu_ui_multi_actions({
            {
                'updateOptions',
                {
                    uiParams = {
                        filer = {
                            fileFilter = input_file_filter,
                        },
                    },
                },
            },
            {
                'redraw',
                {
                    method = 'refreshItems',
                }
            },
        })
    end,
    key_map_opts
)
set_keymap("n", ".",
    function()
        local ddu_custom_get_current = vim.fn['ddu#custom#get_current']
        local current = ddu_custom_get_current(vim.b.ddu_ui_name)
        local source_options = current.sourceOptions or {}
        local source_options_file = source_options.file or {}
        local file_matcher = source_options_file.matchers or {}
        local matcher = {}
        print(vim.inspect(file_matcher))
        print(type(next(file_matcher)))
        print(type(next(file_matcher)) == 'nil')
        if type(next(file_matcher)) == 'nil' then
            matcher = {'matcher_hidden'}
        end

        ddu_ui_multi_actions({
            {
                'updateOptions',
                {
                    sourceOptions = {
                        file = {
                            matchers = matcher,
                        },
                    },
                },
            },
            {
                'redraw',
                {
                    method = 'refreshItems',
                }
            },
        })
    end,
    key_map_opts
)
-- }}}
