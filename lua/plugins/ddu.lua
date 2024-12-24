-- lua_add {{{
-----------------------------------------------------------
-- Ddu configuration file
-----------------------------------------------------------

-- Plugin: ddu.vim
-- url: https://github.com/Shougo/ddu.vim
local set_keymap = vim.keymap.set             -- Set key map
local key_map_opts = { noremap = true, silent = true }

set_keymap(
    'n',
    '<Space>ff',
    function()
        local ddu_start = vim.fn['ddu#start']
        ddu_start({
            name = 'files',
            ui = 'ff',
            sources = {
                {
                    name = 'file',
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
    key_map_opts    
)

set_keymap(
    'n',
    '<Space>fh',
    function()
        local ddu_start = vim.fn['ddu#start']
        ddu_start({
            name = 'files',
            ui = 'ff',
            expandInput = true,
            unique = true,
            sync = true,
            sources = {
                {
                    name = 'file_old'
                },
                {
                    name = 'file',
                    options = {
                        volatile = true
                    },
                    params = {
                        new = true
                    }
                },
                {
                    name = 'file',
                    options = {
                        volatile = true
                    },
                },
            },
            uiParams = {
                ff = {
                    startFilter = true,
                    previewFloating = true,
                    split = 'floating',
                    displaySourceName = 'short'
                }
            }
        })
    end,
    key_map_opts    
)

set_keymap(
    'n',
    '<Space>fg',
    function()
        local keyword = vim.fn.input("Search key: ")
        local ddu_start = vim.fn['ddu#start']
        ddu_start({
            name = 'search',
            ui = 'ff',
            sources = {
                {
                    name = 'rg',
                    params = {
                        input = keyword,
                    }
                },
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
    key_map_opts    
)

set_keymap(
    'n',
    '<Space>fd',
    function()
        local ddu_start = vim.fn['ddu#start']
        local keyword = vim.fn.expand('<cword>')
        ddu_start({
            name = 'gtags',
            ui = 'ff',
            sources = {
                {
                    name = 'gtags',
                    params = {
                        input = keyword,
                    }
                },
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
    key_map_opts    
)

set_keymap(
    'n',
    '<Space>fr',
    function()
        local ddu_start = vim.fn['ddu#start']
        local keyword = vim.fn.expand('<cword>')
        ddu_start({
            name = 'gtags',
            ui = 'ff',
            sources = {
                {
                    name = 'gtags',
                    params = {
                        input = keyword,
                        args = '-r',
                    }
                },
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
    key_map_opts    
)

vim.defer_fn(
    function()
        local ddu_load = vim.fn["ddu#load"]
        ddu_load('files', 'ui', {'ff'})
        ddu_load('files', 'kind', {'file'})
        ddu_load('files', 'source', {'file_old', 'file'})
    end,
700)
-- }}}


-- lua_source {{{
local ddu_load_config = vim.fn["ddu#custom#load_config"]
ddu_load_config(vim.fn.expand("$BASE_DIR/dpp_ext/ddu/ddu.ts"))
-- }}}

-- lua_post_update {{{
local ddu_set_static_import_path = vim.fn["ddu#set_static_import_path"]
ddu_set_static_import_path()
--- }}}
