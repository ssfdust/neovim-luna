-- lua_source {{{
-----------------------------------------------------------
-- Denops Shared Server configuration file
-----------------------------------------------------------

-- Plugin: denops.vim 
-- url: https://github.com/vim-denops/denops.vim

vim.g["denops#debug"] = false
vim.g["denops#server#deno_args"] = {
    "-q",
    "-A"
}
vim.g["denops#server#deno_args"] = vim.list_extend(
    vim.g["denops#server#deno_args"],
    {'--unstable-kv', '--unstable-ffi'}
)
vim.g.denops_server_addr = '127.0.0.1:32123'

-- }}}
