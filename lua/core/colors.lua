-----------------------------------------------------------
-- Color schemes configuration file
-----------------------------------------------------------

-- See: https://github.com/brainfucksec/neovim-lua#appearance

-- Color Schema: kanagawa.nvim
-- Source: https://github.com/rebelot/kanagawa.nvim
-----------------------------------------------------------

local g = vim.g       -- Global variables

g.colorscheme = 'kanagawa-wave'

-----------------------------------------------------------
-- Load color schema
-----------------------------------------------------------

local ok, _ = pcall(vim.cmd, "colorscheme " .. g.colorscheme)

if not ok then
    vim.cmd[[colorscheme slate]]
    return
end
