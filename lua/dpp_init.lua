-----------------------------------------------------------
-- Plugin manager configuration file
-----------------------------------------------------------

-- Plugin manager: dpp.vim
-- url: https://github.com/Shougo/dpp.vim

local set = vim.opt
local fn = vim.fn
local api = vim.api
local autocmd = api.nvim_create_autocmd   -- Create autocommand
local setenv = fn.setenv                 -- set environment

-- Automatically install dpp
local dpp_home = fn.stdpath('data') .. '/dpp'
local dpp_repo = "Shougo/dpp.vim"
local dpp_lazy_repo = "Shougo/dpp-ext-lazy"
local default_branch = "main"
local dpp_ts = fn.fnamemodify(os.getenv('MYVIMRC'), ':h') .. '/dpp_ext/dpp/dpp.ts'

function _exec_init_gitcmds(repo, branch)
    local gitsrc = "https://github.com/" .. repo .. ".git"
    local clone_path = dpp_home .. '/repos/github.com/' .. repo

    if fn.empty(fn.glob(clone_path)) > 0 then
        print("Cloning repo " .. gitsrc .. " with branch " .. branch  .. " to " .. clone_path)
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
        end
    end
    set.runtimepath:append(clone_path)
end

-- 'path' would be init.lua's parent directory.
function activate_dpp()
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
            vim.g.dpp_make_state_done = 1
            vim.notify("dpp make_state() is done")
            vim.defer_fn(
                function() 
                    vim.g.dpp_make_state_done = nil
                    vim.notify("dpp make_state tag is reset")
                end, 
            3000)
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
end

if os.getenv("NO_DPP_INIT") then
    return
else
    setenv("BASE_DIR", fn.fnamemodify(os.getenv('MYVIMRC'), ':h'));
    setenv("DPP_INSTALLER_LOG", dpp_home .. "/dpp-installer.log");
    _exec_init_gitcmds(dpp_repo, default_branch)
    _exec_init_gitcmds(dpp_lazy_repo, default_branch)
    activate_dpp()
end

