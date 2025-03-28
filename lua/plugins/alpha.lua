-- lua_source {{{
-----------------------------------------------------------
-- Alpha Startup configuration file
-----------------------------------------------------------
--
-- Plugin: alpha-nvim
-- url: https://github.com/goolord/alpha-nvim

-- See: :help alpha.txt

local autocmd = vim.api.nvim_create_autocmd   -- Create autocommand

local alpha = require('alpha')
local dashboard = require('alpha.themes.dashboard')

dashboard.section.header.val = {
    [[                               __                ]],
    [[  ___     ___    ___   __  __ /\_\    ___ ___    ]],
    [[ / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\  ]],
    [[/\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \ ]],
    [[\ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\]],
    [[ \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/]],
}

autocmd("User", {
    pattern = "AlphaReady",
    callback = function()
        vim.defer_fn(function()
            if vim.fn.executable('fortune') == 1 then
                local handle = io.popen('fortune')
                local fortune = handle:read("*a")
                handle:close()
                dashboard.section.footer.val = fortune
                vim.cmd('AlphaRedraw')
            end
        end, 5)
    end,
})

dashboard.config.opts.noautocmd = false
dashboard.section.buttons.val = {
    dashboard.button("e", "  New file", "<Cmd>ene <CR>"),
    dashboard.button("SPC f h", "  Find file"),
    dashboard.button("SPC f v", "  Open File Manager"),
    dashboard.button("SPC f g", "  Find word"),
    dashboard.button("SPC s l", "  Open local session", "<Cmd>source .session<CR>"),
    dashboard.button( "q", "  Quit NVIM" , "<Cmd>qa<CR>"),
}

dashboard.config.layout = {
    { type = "padding", val = 6 },
    dashboard.section.header,
    { type = "padding", val = 2 },
    dashboard.section.buttons,
    { type = "padding", val = 3 },
    dashboard.section.footer,
}

alpha.setup(dashboard.config)
-- }}}
