-- lua_source {{{
-----------------------------------------------------------
-- Denops Shared Server configuration file
-----------------------------------------------------------

-- Plugin: denops-shared-server.vim 
-- url: https://github.com/vim-denops/denops-shared-server.vim
local denops_test_client = vim.uv.new_tcp()
local host = vim.g.denops_server_addr:match('([^:]+)')
local port = vim.g.denops_server_addr:match(':([^:]+)')
print(11111)
denops_test_client:connect(
    host,
    port,
    function (err)
        if err == 'ECONNREFUSED' then
            vim.defer_fn(function ()
                install = vim.fn["denops_shared_server#install"]
                install()
            end, 500)
        end
    end
)
-- }}}
