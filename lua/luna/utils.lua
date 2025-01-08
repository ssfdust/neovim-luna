-----------------------------------------------------------
-- Utils module
-----------------------------------------------------------

local fs = vim.fs
local uv = vim.uv

M = {}

-- lua implement for creating directory resursively
function M.fs_mkdir_resursive(path)
    local current_path = path
    local dirs_to_create = {}

    local last_path = fs.dirname(current_path)

    while current_path ~= last_path do
        if not uv.fs_stat(current_path) then
            table.insert(dirs_to_create, current_path)
        end
        current_path = last_path
        last_path = fs.dirname(current_path)
    end

    for i = #dirs_to_create, 1, -1 do
        local dir = dirs_to_create[i]
        uv.fs_mkdir(dir, 493) -- 493 equals 0o755
    end
end

return M
