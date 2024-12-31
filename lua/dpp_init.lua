-----------------------------------------------------------
-- Plugin manager configuration file
-----------------------------------------------------------

-- Plugin manager: dpp.vim
-- url: https://github.com/Shougo/dpp.vim

local set = vim.opt
local fn = vim.fn
local api = vim.api
local fs = vim.fs
local uv = vim.uv
local autocmd = api.nvim_create_autocmd   -- Create autocommand
local setenv = fn.setenv                  -- set environment

-- Automatically install dpp
local dpp_home = fs.joinpath(fn.stdpath('data'), 'dpp')
local dpp_repo = "Shougo/dpp.vim"
local dpp_lazy_repo = "Shougo/dpp-ext-lazy"
local default_branch = "main"
local dpp_ts = fs.joinpath(fs.dirname(os.getenv('MYVIMRC')) ,'dpp_ext/dpp/dpp.ts')

-- set default hub site
vim.g.dpp_hubsite = os.getenv("LUNA_HUBSITE") or "github.com"

local function _get_plugin_path(url)
    local path = url:gsub("%.git$", "")

    path = path:gsub('^https:/+', '')
    path = path:gsub('^git@', '')
    path = path:gsub('/https:/+', '/')

    return path
end

-- local function fs_mkdir_resursive(path)
--     local current_path = path
--     local dirs_to_create = {}
-- 
--     local last_path = vim.fs.dirname(current_path)
-- 
--     while current_path ~= last_path do
--         if not vim.uv.fs_stat(current_path) then
--             table.insert(dirs_to_create, current_path)
--         end
--         current_path = last_path
--         last_path = vim.fs.dirname(current_path)
--     end
-- 
--     for i = #dirs_to_create, 1, -1 do
--         local dir = dirs_to_create[i]
--         vim.uv.fs_mkdir(dir, 493) --  是八进制的 0755
--     end
-- end

local function _exec_init_gitcmds(repo, branch)
    local gitsrc = string.format("https://%s/%s.git", vim.g.dpp_hubsite, repo)
    local clone_path = fs.joinpath(dpp_home, 'repos', _get_plugin_path(gitsrc))

    if fn.empty(fn.glob(clone_path)) > 0 then
        print("Cloning repo " .. gitsrc .. " with branch " .. branch  .. " to " .. clone_path .. " using " .. "git")
        local git_cmds = {
            {"git", "init", "-q", clone_path},
            {"git", "-C", clone_path, "config", "fsck.zeroPaddedFilemode", "ignore"},
            {"git", "-C", clone_path, "config", "fetch.fsck.zeroPaddedFilemode", "ignore"},
            {"git", "-C", clone_path, "config", "receive.fsck.zeroPaddedFilemode", "ignore"},
            {"git", "-C", clone_path, "config", "core.eol", "lf"},
            {"git", "-C", clone_path, "config", "core.autocrlf", "false"},
            {"git", "-C", clone_path, "remote", "add", "origin", gitsrc},
            {"git", "-C", clone_path, "fetch", "--depth=1", "origin", branch},
            {"git", "-C", clone_path, "checkout", branch, "-q"},
        }
        for _, cmd in ipairs(git_cmds) do
            fn.system(cmd)
            while (vim.v.shell_error ~= 0) do
                fn.system(cmd)
            end
        end
    end
    set.runtimepath:append(clone_path)
end

-- local function _save_dpp_repo_state()
--     local dpp_last_repo_path_save = fs.joinpath(dpp_home, '.luna_dpp_repo_path')
--     local current_dpp_repo_path = fs.joinpath(dpp_home, 'repos', _get_plugin_path(table.concat{ vim.g.dpp_hubsite, '/', dpp_repo }))
-- 
--     local last_dpp_repo_path_save_file = io.open(dpp_last_repo_path_save)
--     local last_dpp_repo_path = current_dpp_repo_path
--     local state_updated = false
-- 
--     if not vim.uv.fs_stat(dpp_home) then
--         return state_updated
--     end
-- 
--     if last_dpp_repo_path_save_file ~= nil then
--         last_dpp_repo_path = last_dpp_repo_path_save_file:read() or current_dpp_repo_path
--     end
-- 
--     local old_repo_root = last_dpp_repo_path:gsub(dpp_repo, ''):gsub('/$', '')
--     old_repo_root = uv.fs_realpath(old_repo_root)
--     local new_repo_root = current_dpp_repo_path:gsub(dpp_repo, ''):gsub('/$', '')
-- 
--     if last_dpp_repo_path ~= current_dpp_repo_path then
-- 	state_updated = true
--     end
-- 
--     if old_repo_root ~= new_repo_root and vim.uv.fs_stat(old_repo_root) and not vim.uv.fs_stat(new_repo_root) then
--         vim.notify(string.format("linking '%s' to '%s'", old_repo_root, new_repo_root))
--         fs_mkdir_resursive(vim.fs.dirname(new_repo_root))
--         vim.uv.fs_symlink(old_repo_root, new_repo_root)
--     end
-- 
--     io.open(dpp_last_repo_path_save, 'w'):write(current_dpp_repo_path)
-- 
--     return state_updated
-- end

-- 'path' would be init.lua's parent directory.
local function activate_dpp()
    -- Required:
    -- Add the dpp installation directory into runtimepath

    local dpp = require("dpp")

    if dpp.load_state(dpp_home) then
        -- Add the denops and dpp-ext-installer directory into runtimepath
        local plugins = {
            "Shougo/dpp-ext-installer",
            "Shougo/dpp-ext-packspec",
            "Shougo/dpp-ext-toml",
            "Shougo/dpp-protocol-git",
            "vim-denops/denops.vim",
        }
        for _, repo in ipairs(plugins) do
            _exec_init_gitcmds(repo, default_branch)
        end

        autocmd("User", {
            pattern = "DenopsReady",
            callback = function()
                vim.notify("dpp load_state() is failed")
                dpp.make_state(dpp_home, dpp_ts)
            end,
        })
    else
        autocmd("BufWritePost", {
            pattern = {"*.lua", "*.vim", "*.toml", "*.ts", "vimrc", ".vimrc"},
            callback = function()
                local dpp_check_files = fn["dpp#check_files"]
                dpp_check_files()
            end,
        })
    end
    autocmd("User", {
        pattern = "Dpp:makeStatePost",
        callback = function()
            vim.notify("dpp make_state() is done")
        end,
    })
    autocmd("BufWritePost", {
        pattern = "*.toml",
        callback = function()
            local dpp_sync_ext_action = vim.fn['dpp#sync_ext_action']
            local dpp_async_ext_action = vim.fn['dpp#async_ext_action']
            local not_installed = dpp_sync_ext_action('installer', 'getNotInstalled');
            if type(next(not_installed)) ~= 'nil' then
                dpp_async_ext_action('installer', 'install')
            end
        end,
    })
    vim.cmd("filetype indent plugin on")
    vim.cmd("syntax on")
    -- if reset_dpp then
    --     autocmd("VimEnter", {
    --         callback = function()
    --             dpp.clear_state()
    --             vim.notify("dpp clear_state() is done")
    --             dpp.make_state()
    --         end,
    --     })
    -- end
end

if os.getenv("NO_LUNA_INIT") then
    return
else
    -- local updated = _save_dpp_repo_state()
    setenv("BASE_DIR", fn.fnamemodify(os.getenv('MYVIMRC'), ':h'));
    setenv("DPP_INSTALLER_LOG", dpp_home .. "/dpp-installer.log");
    _exec_init_gitcmds(dpp_repo, default_branch)
    _exec_init_gitcmds(dpp_lazy_repo, default_branch)
    -- activate_dpp(updated)
    activate_dpp()
end

