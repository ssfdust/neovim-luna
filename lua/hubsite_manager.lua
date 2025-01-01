-----------------------------------------------------------
-- Hubsite Manager
-----------------------------------------------------------

local uv = vim.uv
local fs = vim.fs
local autocmd = vim.api.nvim_create_autocmd

local function write_to_file(file, content)
    local handler = io.open(file, 'w')

    handler:write(content)
    handler:close()
end

-- Update the git remote url for dpp git plugins
--
-- This function will iterate every plugin directory, and replace the old hubsite
-- url with the new hubsite url. If there is some submodule in your plugin
-- directory, the url for the submodule won't be updated.
--
-- The process could be a very long time. We need to handle different situations
-- Firstly, we need to reset the repository to the origin, we will have to trigger
-- the branch problem. For non-default branches, we need to reset to the correct
-- branch instead of HEAD.
--
-- At least, for plugins in neovim-luna, this way works.
local function update_hubsite_for_plugins(repository_root, old_hubsite, new_hubsite)
    local submodule_detect = 'git -C "%s" rev-parse --show-superproject-working-tree'
    local git_origin_url = 'git -C "%s" remote get-url origin'
    local git_update_url = 'git -C "%s" remote set-url origin "%s"'
    local git_reset = 'git -C "%s" reset origin/%s --hard'
    local git_plugin_dirs = {}
    local old_origin_url = ''

    for _, entry in ipairs(
        vim.fs.find(
            '.git',
            {
                type = 'directory',
                limit = math.huge,
                path = repository_root,
            }
        )
    ) do
        local handler = io.popen(submodule_detect:format(entry))
        local ret = handler:read('*a')
        handler:close()

        if ret == '' then
            table.insert(git_plugin_dirs, fs.dirname(entry))
        end
    end

    for _, entry in ipairs(git_plugin_dirs) do
        local handler = io.popen(git_origin_url:format(entry))
        local old_origin_url = vim.trim(handler:read('*a'))
        handler:close()

        local new_origin_url = old_origin_url:gsub(old_hubsite, new_hubsite)
        -- vim.notify(string.format('switch origin url of plugin %s from %s to %s', fs.basename(entry), old_origin_url, new_origin_url))

        handler = io.popen(git_update_url:format(entry, new_origin_url))
        handler:close()

        local parts = filename:split("/")
        local reponame = parts[#parts]:gsub('.git$', '')
        local head = 'origin/HEAD'
        if fs.dirname(entry) ~= reponame then
            head = 'origin/' .. entry:gsub(reponame, ''):gsub('_', '')
        end

        handler = io.popen(git_reset:format(entry))
        handler:close()
    end
end

-- The mkdir -p implementation for neovim
local function fs_mkdir_resursive(path)
    local current_path = path
    local dirs_to_create = {}

    local last_path = fs.dirname(current_path)

    while current_path ~= last_path do
        if not vim.uv.fs_stat(current_path) then
            table.insert(dirs_to_create, current_path)
        end
        current_path = last_path
        last_path = fs.dirname(current_path)
    end

    for i = #dirs_to_create, 1, -1 do
        local dir = dirs_to_create[i]
        vim.uv.fs_mkdir(dir, 493) -- 493 equals 0o755
    end
end

function get_plugin_path(url)
    local path = url:gsub("%.git$", "")

    path = path:gsub('^https:/+', '')
    path = path:gsub('^git@', '')
    path = path:gsub('/https:/+', '/')

    return path
end

-- When user change the hubsite, we need to help dpp find the right place for
-- the repository directory.
--
-- For example, the origin hubsite is referred to hubmirrors.org/github.com. some
-- day, user switch the origin hubsite to somesite.com/github.com or github.com
-- the location for dpp repository will change. And the old site may not be
-- accessed any more.
--
-- The origin repository directory is <dpp_home>/repos/hubmirrors.org/github.com
-- then the new repository directory is <dpp_home>/repos/somesite.com/github.com
--
-- What neovim-luna do is to create a symbol link from origin repository directory
-- to the new repository directory. It detects the site change on the state file 
-- <dpp_home>/.luna_dpp_last_hubsite. And the symbol link avoids a lot of issues
function detect_dpp_hubsite_state(current_dpp_hubsite, dpp_home, dpp_repo)
    -- Whether we need to update the repo state
    local state_updated = false
    -- Get the current dpp repository path
    local current_dpp_repo_url = table.concat{ current_dpp_hubsite, '/', dpp_repo }
    local current_dpp_repo_path = fs.joinpath(dpp_home, 'repos', get_plugin_path(current_dpp_repo_url))
    -- Set the default dpp repository path last time to current, skip the unexpected
    -- situation
    local last_dpp_repo_path = current_dpp_repo_path
    local last_dpp_hubsite = current_dpp_hubsite

    -- The state file for saving last time hubsite
    local dpp_last_hubsite_save_path = fs.joinpath(dpp_home, '.luna_dpp_last_hubsite')
    local dpp_last_hubsite_save_handler = io.open(dpp_last_hubsite_save_path)

    -- Skip the detection progress and save the current hubsite when the dpp is
    -- not initilized
    if not vim.uv.fs_stat(dpp_home) then
        write_to_file(dpp_last_hubsite_save_path, current_dpp_hubsite)

        return state_updated
    end

    -- Get the hubsite for last time from .luna_dpp_last_hubsite
    if dpp_last_hubsite_save_handler ~= nil then
        last_dpp_hubsite = dpp_last_hubsite_save_handler:read('*a') or current_dpp_hubsite
        last_dpp_hubsite = vim.trim(last_dpp_hubsite)
        last_dpp_repo_path = fs.joinpath(dpp_home, 'repos', get_plugin_path(table.concat{ last_dpp_hubsite, '/', dpp_repo }))
    end

    if last_dpp_repo_path ~= current_dpp_repo_path then
        state_updated = true
    end

    local old_repo_root = last_dpp_repo_path:gsub(dpp_repo, ''):gsub('/$', '')
    local new_repo_root = current_dpp_repo_path:gsub(dpp_repo, ''):gsub('/$', '')
    local src_repo_root = uv.fs_realpath(old_repo_root)

    -- Create the repository directory and create symbol link to the new location
    if old_repo_root ~= new_repo_root and uv.fs_stat(old_repo_root) and not uv.fs_stat(new_repo_root) then
        local src_repo_root = uv.fs_realpath(old_repo_root)

        vim.notify(string.format("linking '%s' to '%s'", src_repo_root, new_repo_root))

        fs_mkdir_resursive(fs.dirname(new_repo_root))
        uv.fs_symlink(src_repo_root, new_repo_root)

        update_hubsite_for_plugins(src_repo_root, last_dpp_hubsite, current_dpp_hubsite)

        -- When the hubsite is changed, we need to remove the old repository directory
        autocmd("User", {
            pattern = "Dpp:makeStatePost",
            callback = function()
                vim.notify("The hubsite modification is detected, vim will exited after 3 secs")
                vim.defer_fn(function()
                    uv.fs_unlink(old_repo_root)
                    vim.cmd("qall")
                end, 3000)
            end,
        })
    elseif old_repo_root ~= new_repo_root and uv.fs_stat(old_repo_root) and uv.fs_stat(new_repo_root) then
        -- When the hubsite is changed and the repository directory already 
        -- exists, we need to remove the old repository directory as well
        autocmd("User", {
            pattern = "Dpp:makeStatePost",
            callback = function()
                vim.notify("The hubsite modification is detected, vim will exited after 3 secs")
                uv.fs_unlink(old_repo_root)
                vim.defer_fn(function()
                    uv.fs_unlink(old_repo_root)
                    vim.cmd("qall")
                end, 3000)
            end,
        })
    end

    write_to_file(dpp_last_hubsite_save_path, current_dpp_hubsite)

    return state_updated
end
