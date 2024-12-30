-- lua_source {{{
-----------------------------------------------------------
-- lualine configuration file
-----------------------------------------------------------

-- Plugin: lualine
-- url: https://github.com/nvim-lualine/nvim-lualine
local empty = require("lualine.component"):extend()
local opts = require('lualine').get_config()

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

opts.sections["lualine_a"] = add_spacer(opts.sections["lualine_a"], "left")
opts.sections["lualine_z"] = add_spacer(opts.sections["lualine_z"], "right")
opts.options.section_separators = { left = "", right = "" }
opts.options.component_separators = { left = "╲", right = "╱" }

require('lualine').setup(opts)

-- }}}
