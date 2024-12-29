-- lua_add {{{
-----------------------------------------------------------
-- Ddu configuration file
-----------------------------------------------------------

-- Plugin: ddu.vim
-- url: https://github.com/Shougo/ddu.vim
local new_cmd = vim.api.nvim_create_user_command       -- Create custom command

new_cmd('MdPreview', function() require("peek").open() end, {})
new_cmd('MdPreviewClose', function() require("peek").close() end, {})
-- }}}

-- lua_source {{{
require("peek").setup()
-- }}}
