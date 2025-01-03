-----------------------------------------------------------
--  Quickstart configs for Nvim LSP
-----------------------------------------------------------

-- Plugin Name: nvim-lspconfig
-- url: https://github.com/neovim/nvim-lspconfig

-- NOTE: Disable lsp watcher. Too slow on linux
-- https://github.com/neovim/neovim/issues/23725#issuecomment-1561364086
-- lua_source {{{
require('vim.lsp._watchfiles')._watchfunc = function()
    return function() end
end

vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        update_in_insert = false,
        virtual_text = {
            severity = {
                min = 'WARN',
            },
            severity_sort = true,
            format = function(diagnostic)
                if diagnostic.code then
                    return string.format(
                        '%s (%s: %s)',
                        diagnostic.message,
                        diagnostic.source,
                        diagnostic.code
                    )
                else
                    return string.format(
                        '%s (%s)',
                        diagnostic.message,
                        diagnostic.source
                    )
                end
            end,
        },
    })
-- }}}
