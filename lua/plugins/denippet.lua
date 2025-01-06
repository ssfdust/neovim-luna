-----------------------------------------------------------
--  A snippet plugin for Vim/Neovim
-----------------------------------------------------------

-- Plugin Name: denippet.vim
-- url: https://github.com/uga-rosa/denippet.vim
-- lua_add {{{
local set_keymap = vim.keymap.set           -- Set key map
local key_map_opts = { noremap = true, silent = true}

set_keymap('i', '<c-j>', "<Plug>(denippet-expand-or-jump)", key_map_opts)
set_keymap('i', '<c-k>', "<Plug>(denippet-jump-prev)", key_map_opts)
-- }}}

-- lua_source {{{
local fs = vim.fs
local fn = vim.fn
local dpp = require("dpp")

local snip_plugin = dpp.get("friendly-snippets") or nil
local snip_plugin_path = snip_plugin and snip_plugin.path or nil

-- Load snippet file from directory
--
-- A snippet directory:
-- snippets
-- -- [[ filetype-A ]]
-- -- -- snippet-01.json
-- -- -- snippet-02.json
-- -- [[ filetype-B ]]
-- -- -- snippet-01.json
-- -- -- snippet-02.json
-- -- [[ filetype-C ]].json
local function load_from_snippets_dir(snippets_dir)
    if snip_plugin_path ~= nil then
        local snippet_files = vim.fs.find(function(name, _)
                return name:match('.*%.json$') ~= nil
            end,
            {
                limit = math.huge,
                type = 'file',
                path = fs.joinpath(snip_plugin_path, "snippets"),
            }
        )
        for _, snip_file in ipairs(snippet_files) do
            -- We assert all snippets stored in the `snippets` directory, and
            -- the sub directory name must be the filetype, the max depth
            -- mustn't be over 2 levels. So parent directory of any json file
            -- in snippet directory should be the filetype or `snippets`.
            local parent = fs.basename(fs.dirname(snip_file))
            if parent == 'snippets' then
                fn['denippet#load'](snip_file)
            else
                fn['denippet#load'](snip_file, {parent})
            end
        end
    end
end

load_from_snippets_dir(snip_plugin_path)

-- }}}
