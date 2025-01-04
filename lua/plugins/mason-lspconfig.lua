-----------------------------------------------------------
-- Extension to mason-lspconfig.nvim
-----------------------------------------------------------

-- Plugin Name: mason-lspconfig.nvim
-- url: https://github.com/williamboman/mason-lspconfig.nvim

-- NOTE: Disable lsp watcher. Too slow on linux
-- https://github.com/neovim/neovim/issues/23725#issuecomment-1561364086
-- lua_source {{{
local fs = vim.fs

local nvim_lsp = require('lspconfig')

local handlers = {
    vtsls = function()
        local project_file = fs.find(
            'package.json', { limit = 1, type = 'file', path = '.' }
        )
        if #project_file == 0 then
            return
        end
        return { root_dir = nvim_lsp.util.root_pattern('package.json') }
    end,
    lua_ls = function()
        return {
            settings = {
                Lua = {
                    runtime = {
                        -- Tell the language server which version of Lua you're using
                        -- (most likely LuaJIT in the case of Neovim)
                        version = 'LuaJIT',
                    },
                    diagnostics = {
                        -- Get the language server to recognize the `vim` global
                        globals = {
                            'vim',
                            'require',
                        },
                    },
                    workspace = {
                        -- Make the server aware of Neovim runtime files
                        library = vim.api.nvim_get_runtime_file("", true),
                    },
                    -- Do not send telemetry data
                    telemetry = {
                        enable = false,
                    },
                },
            },
        }
    end,
    rust_analyzer = function()
        local capabilities = require("ddc_source_lsp").make_client_capabilities()
        return { capabilities = capabilities }
    end,
}

require('mason-lspconfig').setup_handlers({
    function(server_name)
        local options = {}
        if handlers[server_name] ~= nil then
            options = handlers[server_name]() or {}
        end
        nvim_lsp[server_name].setup(options)
    end
})

-- }}}
