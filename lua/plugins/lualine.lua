-- lua_source {{{
-----------------------------------------------------------
-- lualine configuration file
-----------------------------------------------------------

-- Plugin: lualine
-- url: https://github.com/nvim-lualine/nvim-lualine

-- Origin from https://github.com/LazyVim/LazyVim/discussions/5226

local options = require('lualine.config').get_config()
local empty = require("lualine.component"):extend()
function empty:draw(default_highlight)
    self.status = ""
    self.applied_separator = ""
    self:apply_highlights(default_highlight)
    self:apply_section_separators()
    return self.status
end

-- Only works for sections with a single component in them,
-- but that's all I need anyways.
local function add_spacer(section, side)
    local left = side == "left"
    local separator = left and { right = "" } or { left = "" }
    section[1] = { section[1], separator = separator }
    local spacer = { empty, separator = separator }
    table.insert(section, left and #section + 1 or 1, spacer)
    return section
end

options.sections["lualine_a"] = add_spacer(options.sections["lualine_a"], "left")
options.sections["lualine_z"] = add_spacer(options.sections["lualine_z"], "right")
options.options.section_separators = { left = "", right = "" }
options.options.component_separators = { left = "╲", right = "╱" }
options.theme = vim.g.colorscheme

require('lualine').setup(options)

-- }}}
