-----------------------------------------------------------
-- Dark deno-powered completion framework
-----------------------------------------------------------

-- Plugin Name: ddc.vim
-- url: https://github.com/Shougo/ddc.vim
-- lua_add {{{
local buffer = vim.b
local fn = vim.fn
local api = vim.api

local autocmd = vim.api.nvim_create_autocmd
local set_keymap = vim.keymap.set
local key_map_opts = { noremap = true, silent = true }

function CommandlinePost()
    if buffer.prev_buffer_config ~= nil then
        fn['ddc#custom#set_buffer'](buffer.prev_buffer_config)
        buffer.prev_buffer_config = nil
    end
end

function CommandlinePre(mode)
    buffer.prev_buffer_config = fn['ddc#custom#get_buffer']()

    if mode == ':' then
        -- For :! completion

        -- update cmdline completion to use the sources we defined
        fn["ddc#custom#set_context_buffer"](function()
            local context_buffer_patch = {}
            if fn.getcmdline():match('^!') ~= nil then
                context_buffer_patch = {
                    cmdlineSources = {
                        'shell_native', 'cmdline', 'cmdline_history', 'around'
                    }
                }
            end
            return context_buffer_patch
        end)
        
        -- global completion configuration
        fn['ddc#custom#patch_buffer']("sourceOptions", {
            _ = {
                keywordPattern = '[0-9a-zA-Z_:#-]*',
            }
        })

        -- Call post actions only once when leave the command line input
        autocmd('User', {
            pattern = 'DDCCmdlineLeave',
            once = true,
            callback = function() CommandlinePost() end,
        })

        fn['ddc#enable_cmdline_completion']()
    end
end

set_keymap({"n", "x"}, ":",
    function()
        CommandlinePre(':')
        api.nvim_feedkeys(":", "n", true)
    end,
    key_map_opts
)
set_keymap("n", "/",
    function()
        CommandlinePre('/')
        api.nvim_feedkeys("/", "n", true)
    end,
    key_map_opts
)

-- }}}

-- lua_source {{{
local fn = vim.fn
local fs = vim.fs

local autocmd = vim.api.nvim_create_autocmd
local set_keymap = vim.keymap.set
local key_map_opts = { noremap = true, silent = true }
local key_map_expr = { noremap = true, replace_keycodes = false, expr = true }

local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end


fn['ddc#custom#load_config'](fs.joinpath(os.getenv('BASE_DIR'), 'dpp_ext', 'ddc', 'ddc.ts'))

-- Key maps for insert mode
set_keymap('i', '<S-Tab>', function() fn['pum#map#insert_relative'](-1, 'empty') end, key_map_opts)
set_keymap('i', '<C-n>', function() fn['pum#map#select_relative'](1) end, key_map_opts)
set_keymap('i', '<C-p>', function() fn['pum#map#select_relative'](-1) end, key_map_opts)
set_keymap('i', '<C-y>', function() fn['pum#map#confirm_suffix']() end, key_map_opts)
set_keymap('i', '<C-o>', function() fn['pum#map#confirm_word']() end, key_map_opts)
set_keymap('i', '<C-g>', function() fn['pum#map#toggle_preview']() end, key_map_opts)

set_keymap('i', '<C-g>', function() return fn['ddc#map#insert_item'](0) end, key_map_expr)
set_keymap('c', '<C-g>', function() return fn['ddc#map#insert_item'](0) end, key_map_expr)

set_keymap("i", "<C-e>",
    function()
        if fn["ddc#ui#inline#visible"]() ~= 0 then
            return fn["ddc#map#insert_item"](0)
        elseif fn['pum#visible']() then
            return t([[<Cmd>call pum#map#cancel()<CR>]])
        else
            return t("<C-g>U<End>")
        end
    end,
    key_map_expr
)
set_keymap("i", "<Tab>",
    function()
        if vim.fn['ddc#ui#inline#visible']() ~= 0 then
            return vim.fn['ddc#map#insert_item'](0)
        elseif fn['pum#visible']() then
            return t([[<Cmd>call pum#map#insert_relative(+1, "empty")<CR>]])
        else
            local col = fn.col(".")
            if col <= 1 then
                return t("<Tab>")
            else
                if string.match(vim.fn.getline("."):sub(-2, -2), "%s") ~= nil then
                    return t("<Tab>")
                else
                    vim.fn["ddc#map#manual_complete"]()
                end
            end
        end
    end,
    key_map_expr
)

-- Terminal completion
set_keymap('c', '<S-Tab>', function() fn['pum#map#insert_relative'](-1) end, key_map_opts)
set_keymap('c', '<C-q>', function() fn['pum#map#select_relative'](1) end, key_map_opts)
set_keymap('c', '<C-z>', function() fn['pum#map#select_relative'](-1) end, key_map_opts)
set_keymap('c', '<C-o>', function() fn['pum#map#confirm']() end, key_map_opts)

set_keymap("c", "<C-e>",
    function()
        if fn["ddc#ui#inline#visible"]() ~= 0 then
            return fn["ddc#map#insert_item"](0)
        elseif fn['pum#visible']() then
            return t([[<Cmd>call pum#map#cancel()<CR>]])
        else
            return t("<End>")
        end
    end,
    key_map_expr
)

set_keymap("c", "<Tab>",
    function()
        if vim.fn['ddc#ui#inline#visible']() ~= 0 then
            return vim.fn['ddc#map#insert_item'](0)
        elseif fn['pum#visible']() then
            return t([[<Cmd>call pum#map#insert_relative(+1)<CR>]])
        else
            vim.fn["ddc#map#manual_complete"]()
        end
    end,
    key_map_expr
)

set_keymap("x", "<Tab>", [["_R<Cmd>call ddc#map#manual_complete()<CR>]])
set_keymap("s", "<Tab>", [[<C-o>"_di<Cmd>call ddc#map#manual_complete()<CR>]])

fn['ddc#enable_terminal_completion']()
fn['ddc#enable']({ context_filetype = 'treesitter' })
-- }}}

-- lua_post_update {{{
vim.fn["ddc#set_static_import_path"]()
-- }}}
