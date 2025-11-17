-- Neovim Keymaps
-- Custom keybindings

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- ============================================================================
-- General
-- ============================================================================

-- Clear search highlighting
keymap("n", "<leader><space>", ":nohlsearch<CR>", opts)

-- Save file
keymap("n", "<leader>w", ":w<CR>", opts)

-- Quit
keymap("n", "<leader>q", ":q<CR>", opts)

-- Save and quit
keymap("n", "<leader>x", ":x<CR>", opts)

-- Force quit
keymap("n", "<leader>Q", ":q!<CR>", opts)

-- Select all
keymap("n", "<C-a>", "gg<S-v>G", opts)

-- ============================================================================
-- Window Navigation
-- ============================================================================

-- Navigate windows
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Resize windows
keymap("n", "<C-Up>", ":resize -2<CR>", opts)
keymap("n", "<C-Down>", ":resize +2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Split windows
keymap("n", "<leader>|", ":vsplit<CR>", opts)
keymap("n", "<leader>-", ":split<CR>", opts)

-- ============================================================================
-- Buffer Navigation
-- ============================================================================

-- Next/previous buffer
keymap("n", "<Tab>", ":bnext<CR>", opts)
keymap("n", "<S-Tab>", ":bprevious<CR>", opts)

-- Close buffer
keymap("n", "<leader>c", ":bdelete<CR>", opts)

-- ============================================================================
-- Editing
-- ============================================================================

-- Move lines up/down
keymap("n", "<A-j>", ":m .+1<CR>==", opts)
keymap("n", "<A-k>", ":m .-2<CR>==", opts)
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", opts)
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", opts)

-- Better indenting
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Duplicate line
keymap("n", "<leader>d", "yyp", opts)

-- Delete without yanking
keymap("n", "<leader>D", '"_d', opts)
keymap("v", "<leader>D", '"_d', opts)

-- Paste without yanking
keymap("v", "p", '"_dP', opts)

-- ============================================================================
-- File Explorer (nvim-tree)
-- ============================================================================

keymap("n", "<leader>e", ":NvimTreeToggle<CR>", opts)
keymap("n", "<leader>E", ":NvimTreeFocus<CR>", opts)

-- ============================================================================
-- Telescope
-- ============================================================================

keymap("n", "<leader>ff", ":Telescope find_files<CR>", opts)
keymap("n", "<leader>fg", ":Telescope live_grep<CR>", opts)
keymap("n", "<leader>fb", ":Telescope buffers<CR>", opts)
keymap("n", "<leader>fh", ":Telescope help_tags<CR>", opts)
keymap("n", "<leader>fr", ":Telescope oldfiles<CR>", opts)

-- ============================================================================
-- Git (gitsigns)
-- ============================================================================

keymap("n", "<leader>gb", ":Gitsigns blame_line<CR>", opts)
keymap("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", opts)
keymap("n", "<leader>gr", ":Gitsigns reset_hunk<CR>", opts)
keymap("n", "<leader>gs", ":Gitsigns stage_hunk<CR>", opts)
keymap("n", "<leader>gu", ":Gitsigns undo_stage_hunk<CR>", opts)

-- ============================================================================
-- LSP
-- ============================================================================

-- See `:help vim.lsp.*` for documentation
keymap("n", "gD", vim.lsp.buf.declaration, opts)
keymap("n", "gd", vim.lsp.buf.definition, opts)
keymap("n", "K", vim.lsp.buf.hover, opts)
keymap("n", "gi", vim.lsp.buf.implementation, opts)
keymap("n", "<C-k>", vim.lsp.buf.signature_help, opts)
keymap("n", "<leader>rn", vim.lsp.buf.rename, opts)
keymap("n", "<leader>ca", vim.lsp.buf.code_action, opts)
keymap("n", "gr", vim.lsp.buf.references, opts)
keymap("n", "<leader>f", vim.lsp.buf.format, opts)

-- ============================================================================
-- Diagnostics
-- ============================================================================

keymap("n", "<leader>di", vim.diagnostic.open_float, opts)
keymap("n", "[d", vim.diagnostic.goto_prev, opts)
keymap("n", "]d", vim.diagnostic.goto_next, opts)
keymap("n", "<leader>dl", vim.diagnostic.setloclist, opts)

-- ============================================================================
-- Terminal
-- ============================================================================

-- Open terminal
keymap("n", "<leader>t", ":terminal<CR>", opts)

-- Terminal mode escape
keymap("t", "<Esc>", "<C-\\><C-n>", opts)
