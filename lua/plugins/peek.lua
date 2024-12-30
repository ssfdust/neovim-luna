-- lua_source {{{
-----------------------------------------------------------
-- Ddu configuration file
-----------------------------------------------------------

-- Plugin: peek.vim
-- url: https://github.com/toppair/peek.nvim
local new_cmd = vim.api.nvim_create_user_command       -- Create custom command

new_cmd('MdPreview', function() require("peek").open() end, {})
new_cmd('MdPreviewClose', function() require("peek").close() end, {})
require("peek").setup()
-- }}}
