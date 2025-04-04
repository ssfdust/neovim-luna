-----------------------------------------------------------
-- Key Mapping
-----------------------------------------------------------

-- Define keymaps with Lua APIs

local set_keymap = vim.keymap.set             -- Set key map

local function map(mode, lhs, rhs, opts)
  local options = { noremap=true, silent=true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  set_keymap(mode, lhs, rhs, options)
end

-- Disable arrow keys
map('', '<up>', '<nop>')
map('', '<down>', '<nop>')
map('', '<left>', '<nop>')
map('', '<right>', '<nop>')

-- Ctrl-S for save
map('i', '<C-s>', '<Esc><Cmd>w<CR>i')
map('n', '<C-s>', '<Cmd>w<CR>')

-- Termnal
map('t', '<Esc>', '<C-\\><C-n>')

-- Change directory to file path
map('n', '<leader>cd', "<Cmd>lua require('core/utils').change_dir()<CR>", { noremap=false})

-- Cancel search highlight
map('n', '<leader><Esc>', '<Cmd>noh<CR>')

-- Copy file path
map('n', '<leader>fy', "<Cmd>lua require('core/utils').get_filepath()")

-- Switch window by number key
for i=1, 9 do
    map('n', '<leader>' .. i, "<Cmd>lua require('core/utils').switch_window(" .. i .. ")<CR>")
end

-- Map write with sudo
map('c', 'w!!', "<Cmd>lua require('core/utils').super_write()<CR>")

-- Quit
map('n', 'gq', ':quit<CR>')
