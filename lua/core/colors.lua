-----------------------------------------------------------
-- Color schemes configuration file
-----------------------------------------------------------

-- See: https://github.com/brainfucksec/neovim-lua#appearance

-- Color Schema: gruvbox-flat
-----------------------------------------------------------

local g = vim.g       -- Global variables

g.colorscheme = 'gruvbox-flat'
g.gruvbox_flat_style = "dark"

local ok, config = pcall(require, "gruvbox.config")

if ok then
    local colors = require("gruvbox.colors").setup(config)
    g.gruvbox_theme = {
        TabLineSel = {
            fg = colors.bg_statusline,
            bg = colors.green
        },
        WarningMsg = { fg = colors.yellow2 }
    }
end


-----------------------------------------------------------
-- Load color schema
-----------------------------------------------------------

local ok, _ = pcall(vim.cmd, "colorscheme " .. g.colorscheme)

if not ok then
    pcall(vim.cmd, "colorscheme " .. "slate")
    return
end
