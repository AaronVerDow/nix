-- Old style tab completion
vim.opt.wildmode = "longest:list"
vim.opt.wildmenu = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true

-- Make line numbers default
-- vim.opt.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.opt.relativenumber = true

-- map shift-ctrl-c to yank to system buffer
vim.api.nvim_set_keymap('v', '<C-S-c>', '"+y', { noremap = true, silent = true })

-- https://github.com/HiPhish/rainbow-delimiters.nvim/issues/2
-- ChatGPT suggested the delay and it worked.
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    callback = function()
        vim.defer_fn(function()
            vim.cmd("TSBufEnable highlight")
        end, 100) -- Delay by 100 milliseconds
    end,
})

require('gitsigns').setup()
require('lualine').setup()
require("typescript-tools").setup {}
require('transparent').setup({})
---@class CinnamonOptions
require("cinnamon").setup {
    -- Disable the plugin
    disabled = false,

    keymaps = {
        -- Enable the provided 'basic' keymaps
        basic = true,
        -- Enable the provided 'extra' keymaps
        extra = true,
    },
    
    ---@class ScrollOptions
    options = {
        -- The scrolling mode
        -- `cursor`: animate cursor and window scrolling for any movement
        -- `window`: animate window scrolling ONLY when the cursor moves out of view
        mode = "window",

        -- Only animate scrolling if a count is provided
        count_only = false,

        -- Delay between each movement step (in ms)
        delay = 5,

        max_delta = {
            -- Maximum distance for line movements before scroll
            -- animation is skipped. Set to `false` to disable
            line = false,
            -- Maximum distance for column movements before scroll
            -- animation is skipped. Set to `false` to disable
            column = false,
            -- Maximum duration for a movement (in ms). Automatically scales the
            -- delay and step size
            time = 1000,
        },

        step_size = {
            -- Number of cursor/window lines moved per step
            vertical = 1,
            -- Number of cursor/window columns moved per step
            horizontal = 20,
        },

        -- Optional post-movement callback. Not called if the movement is interrupted
        callback = function() end,
    },
}

vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*.puml",
    callback = function()
        vim.cmd("PlantumlOpen")
    end,
})

-- double tap escape to clear search highlights
-- next still works and will reenable highlights
local escape_count = 0
local last_escape_time = 0
vim.keymap.set('n', '<Esc>', function()
  local current_time = vim.loop.now()
  if current_time - last_escape_time < 300 then -- threshold
    escape_count = escape_count + 1
    if escape_count >= 1 then -- tap count
      vim.cmd('nohlsearch')
      escape_count = 0
    end
  else
    escape_count = 0
  end
  last_escape_time = current_time
  return '<Esc>'
end, { expr = true, noremap = true })

-- soft wrap
vim.opt.wrap = true
vim.opt.linebreak = true  -- Wrap at word boundaries (prevents breaking words)
vim.opt.breakindent = true  -- Maintain indentation on wrapped lines
vim.opt.showbreak = '↪ '  -- Show a symbol for wrapped lines

-- automatic hard line wrap
-- keeping this because I like this setup
-- vim.api.nvim_create_autocmd('FileType', {
  -- pattern = { 'markdown', 'rmd' }, callback = function()
    -- vim.bo.formatoptions = vim.bo.formatoptions .. 'tcqj'
    -- vim.bo.textwidth = 80  -- Set your desired line length
    -- vim.bo.wrapmargin = 0  -- Ensure textwidth is used instead
    -- vim.bo.formatoptions = vim.bo.formatoptions .. 'a'  -- Auto-wrap text while typing
  -- end
-- })
