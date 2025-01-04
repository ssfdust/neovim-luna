-----------------------------------------------------------
-- Extension to mason.nvim
-----------------------------------------------------------

-- Plugin Name: mason.nvim
-- url: https://github.com/williamboman/mason-lspconfig.nvim

-- NOTE: Disable lsp watcher. Too slow on linux
-- https://github.com/neovim/neovim/issues/23725#issuecomment-1561364086
-- lua_source {{{
local github_url_template = table.concat {
    "https://",
    vim.g.dpp_hubsite,
    "/%s/releases/download/%s/%s"
}
require("mason").setup {
    github = {
        download_url_template = github_url_template,
    },
}
-- }}}
