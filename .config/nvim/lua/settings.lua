-- Neovim Core Settings
-- General editor settings

local opt = vim.opt
local g = vim.g

-- ============================================================================
-- General
-- ============================================================================

-- Leader key
g.mapleader = " "
g.maplocalleader = " "

-- Disable netrw (use nvim-tree instead)
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1

-- ============================================================================
-- UI
-- ============================================================================

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Cursor line
opt.cursorline = true

-- Show sign column
opt.signcolumn = "yes"

-- Color column
opt.colorcolumn = "80,120"

-- Show mode in statusline
opt.showmode = false

-- Show command
opt.showcmd = true

-- Split windows
opt.splitright = true
opt.splitbelow = true

-- Scroll offset
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Wrap lines
opt.wrap = false

-- Show invisible characters
opt.list = true
opt.listchars = { tab = '→ ', trail = '·', nbsp = '␣' }

-- Popup menu height
opt.pumheight = 10

-- Enable 24-bit RGB colors
opt.termguicolors = true

-- ============================================================================
-- Editing
-- ============================================================================

-- Tab settings
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true

-- Auto indent
opt.autoindent = true
opt.smartindent = true

-- Backspace behavior
opt.backspace = "indent,eol,start"

-- Clipboard
opt.clipboard = "unnamedplus"

-- Mouse support
opt.mouse = "a"

-- Undo settings
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undo"

-- Backup and swap
opt.backup = false
opt.writebackup = false
opt.swapfile = false

-- Update time (for better UX)
opt.updatetime = 300

-- Timeout
opt.timeoutlen = 500

-- ============================================================================
-- Search
-- ============================================================================

-- Search settings
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- ============================================================================
-- Completion
-- ============================================================================

-- Completion options
opt.completeopt = "menu,menuone,noselect"

-- ============================================================================
-- Filetype
-- ============================================================================

-- Enable filetype detection, plugins, and indent
vim.cmd([[
  filetype plugin indent on
]])

-- ============================================================================
-- Performance
-- ============================================================================

-- Faster completion
opt.updatetime = 250

-- Don't pass messages to |ins-completion-menu|
opt.shortmess:append("c")

-- ============================================================================
-- Autocommands
-- ============================================================================

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
  end,
})

-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
})

-- Return to last edit position
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
