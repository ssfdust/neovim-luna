-----------------------------------------------------------
--  Dark deno powered Terminal interface for Vim/Neovim 
-----------------------------------------------------------

-- Plugin Name: ddt.vim
-- url: https://github.com/Shougo/ddt.vim

-- lua_add {{{
local set_keymap = vim.keymap.set             -- Set key map
local key_map_opts = { noremap = true, silent = true }

local ddt_start = vim.fn['ddt#start']

set_keymap(
    'n',
    '<Space>t',
    function()
        local HEIGHT_RATIO = 0.5
        local WIDTH_RATIO = 0.7
        local ddt_name = vim.t.ddt_ui_terminal_last_name or ('terminal-' .. vim.fn.win_getid())
        local screen_w = vim.opt.columns:get()
        local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
        local window_w = screen_w * WIDTH_RATIO
        local window_h = screen_h * HEIGHT_RATIO
        local window_w_int = math.floor(window_w)
        local window_h_int = math.floor(window_h)
        local center_x = (screen_w - window_w) / 2
        local center_y = ((vim.opt.lines:get() - window_h) / 2)
                         - vim.opt.cmdheight:get()
        ddt_start({
            name = ddt_name,
            ui = 'terminal',
            uiParams = {
                terminal = {
                    winWidth = window_w_int,
                    winCol = center_x,
                    winRow = center_y,
                    winHeight = window_h_int,
                },
            },
        })
    end,
    key_map_opts
)
-- }}}

-- lua_source {{{
local fn = vim.fn
local set_keymap = vim.keymap.set
local key_map_opts = { noremap = true, silent = true }
local key_map_expr = { noremap = true, replace_keycodes = false, expr = true }
local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local ddt_patch_global = vim.fn['ddt#custom#patch_global']
local shell = os.getenv('SHELL')
local prompt_pattern = os.getenv("PS1") or "% "

if fn.executable('nu') == 1 then
    shell = 'nu'
    prompt_pattern = ".* "
elseif fn.executable('zsh') == 1 then
    shell = 'zsh'
end

ddt_patch_global({
    ui = "terminal",
    uiParams = {
        terminal = {
            command = {shell},
            split = "floating",
            promptPattern = prompt_pattern,
        }
    }
})
set_keymap("t", "<C-t>", "<Tab>", key_map_opts)
set_keymap("t", "<Tab>",
    function()
        if fn['pum#visible']() then
            return t([[<Cmd>call pum#map#select_relative(+1)<CR>]])
        else
            return t("<Tab>")
        end
    end,
    key_map_expr
)
set_keymap("t", "<S-Tab>",
    function()
        if fn['pum#visible']() then
            return t([[<Cmd>call pum#map#select_relative(-1)<CR>]])
        else
            return t("<S-Tab>")
        end
    end,
    key_map_expr
)
set_keymap("t", "<Down>",
    function()
        fn['pum#map#insert_relative'](1)
    end,
    key_map_opts
)
set_keymap("t", "<Up>",
    function()
        fn['pum#map#insert_relative'](-1)
    end,
    key_map_opts
)
set_keymap('t', '<C-y>', function() fn['pum#map#confirm']() end, key_map_opts)
set_keymap('t', '<C-o>', function() fn['pum#map#confirm']() end, key_map_opts)
-- }}}

-- lua_ddt-terminal {{{
local set_keymap = vim.keymap.set
local key_map_opts = { noremap = true, silent = true, buffer = true }

local ddt_ui_do_action = vim.fn["ddt#ui#do_action"]
set_keymap('n', '<C-n>', function() ddt_ui_do_action('nextPrompt') end, key_map_opts)
set_keymap('n', '<C-p>', function() ddt_ui_do_action('previousPrompt') end, key_map_opts)
set_keymap('n', '<C-y>', function() ddt_ui_do_action('pastePrompt') end, key_map_opts)
set_keymap('n', '<CR>', function() ddt_ui_do_action('executeLine') end, key_map_opts)
-- }}}
