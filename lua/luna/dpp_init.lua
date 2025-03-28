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

local utils = require("luna/utils")

local dpp_home = fs.joinpath(fn.stdpath('data'), 'dpp')

-- Set global enviromnent
setenv("BASE_DIR", fs.dirname(uv.fs_realpath(os.getenv('MYVIMRC'))));
setenv("DPP_INSTALLER_LOG", fs.joinpath(dpp_home, "dpp-installer.log"));

-- Automatically install dpp
local dpp_repo = "Shougo/dpp.vim"
local dpp_lazy_repo = "Shougo/dpp-ext-lazy"
local default_branch = "main"
local dpp_ts = fs.joinpath(os.getenv('BASE_DIR') ,'dpp_ext', 'dpp', 'dpp.ts')

-- set default hub site
vim.g.dpp_hubsite = os.getenv("LUNA_HUBSITE") or "github.com"

local function _exec_init_gitcmds(repo, branch)
    local gitsrc = string.format("https://%s/%s.git", vim.g.dpp_hubsite, repo)
    local clone_path = fs.joinpath(dpp_home, 'repos', get_plugin_path(gitsrc))

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

local function inst_plugins()
    local not_installed = fn['dpp#sync_ext_action']('installer', 'getNotInstalled');
    if type(next(not_installed)) ~= 'nil' then
        fn['dpp#async_ext_action']('installer', 'install')
    end
end

-- 'path' would be init.lua's parent directory.
local function activate_dpp(reset_dpp)
    -- Required:
    -- Add the dpp installation directory into runtimepath

    local dpp = require("dpp")

    if dpp.load_state(dpp_home) then
        -- vim.g.denops_server_addr = '127.0.0.1:12345'
        -- Add the denops and dpp-ext-installer directory into runtimepath
        local plugins = {
            "Shougo/dpp-ext-installer",
            "Shougo/dpp-ext-toml",
            "Shougo/dpp-protocol-git",
            "vim-denops/denops.vim",
        }
        for _, repo in ipairs(plugins) do
            _exec_init_gitcmds(repo, default_branch)
        end
        vim.cmd[[runtime! plugin/denops.vim]]

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
                dpp.check_files()
            end,
        })
        if reset_dpp then
            autocmd("User", {
                pattern = "DenopsReady",
                callback = function()
                    dpp.clear_state()
                    vim.notify("dpp clear_state() is done")
                    dpp.make_state()
                end,
            })
        else
            autocmd("User", {
                pattern = "DenopsReady",
                callback = function()
                    local is_headless = #api.nvim_list_uis() == 0
                    if not is_headless then
                        inst_plugins()
                    end
                end,
            })
        end
        autocmd("BufWritePost", {
            pattern = "*.toml",
            callback = inst_plugins,
        })
    end
    autocmd("User", {
        pattern = "Dpp:makeStatePost",
        callback = function()
            vim.notify("dpp make_state() is done")
        end,
    })
    vim.cmd("filetype indent plugin on")
    vim.cmd("syntax on")

end

-- Start the custom neovim rpc server, we need to define the server addrees.
local function create_server_pipe()
    local pipedir = fs.joinpath(fn.stdpath('run'), 'nvim', 'rpc')
    vim.g.rpc_server_addr = fs.joinpath(pipedir, "nvim-server.sock")
    utils.fs_mkdir_resursive(pipedir)
    if not uv.fs_stat(vim.g.rpc_server_addr) then
        fn.serverstart(vim.g.rpc_server_addr)
    end
end

if os.getenv("NO_LUNA_INIT") then
    return
else
    local updated = detect_dpp_hubsite_state(vim.g.dpp_hubsite, dpp_home, dpp_repo)
    _exec_init_gitcmds(dpp_repo, default_branch)
    _exec_init_gitcmds(dpp_lazy_repo, default_branch)
    utils.fs_mkdir_resursive(fn.stdpath("cache"))
    -- create_server_pipe()
    activate_dpp(updated)
end

