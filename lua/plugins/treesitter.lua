-- lua_source {{{
-----------------------------------------------------------
-- Treesitter configuration file
----------------------------------------------------------

-- Plugin: nvim-treesitter
-- url: https://github.com/nvim-treesitter/nvim-treesitter

local status_ok, nvim_treesitter = pcall(require, 'nvim-treesitter.configs')
if not status_ok then
  return
end

local status_ok, nvim_treesitter_parsers = pcall(require, 'nvim-treesitter.parsers') if not status_ok then
  return
end

if (vim.fn.executable('gcc') == 1) then
    vim.g.treesitter_ensure_installed = {
        'bash', 'c', 'cpp', 'css', 'html', 'javascript', 'json', 'lua', 'python',
        'rust', 'typescript', 'vim', 'yaml', 'nu'
    }
else
    vim.g.treesitter_ensure_installed = {}
end

-- Nu Language support
local parser_config = nvim_treesitter_parsers.get_parser_configs()
parser_config.nu = {
  install_info = {
    url = "https://github.com/nushell/tree-sitter-nu",
    files = { "src/parser.c" },
    branch = "main",
  },
  filetype = "nu",
}

if os.getenv("NO_ENSURE_TREESITTER") then
    return
end

if (vim.g.dpp_hubsite ~= nil and vim.g.dpp_hubsite ~= 'github.com') then
    for _, config in pairs(require("nvim-treesitter.parsers").get_parser_configs()) do
      config.install_info.url = config.install_info.url:gsub("https://github.com/", "https://" .. vim.g.dpp_hubsite .. '/')
    end
end

-- See: https://github.com/nvim-treesitter/nvim-treesitter#quickstart
nvim_treesitter.setup {
  auto_install = false,
  -- A list of parser names, or "all"
  ensure_installed = vim.g.treesitter_ensure_installed,
  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = true,
  highlight = {
    -- `false` will disable the whole extension
    enable = true,
  },
}

-- }}}
