local opts = { noremap = true, silent = true }

local keymap = vim.keymap.set

-- Remap space as leader key
keymap("", "<space>", "<nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local M = {}

M.general = {
  i = {
    -- go to begging and end
    ["<C-b>"] = { "<ESC>^i", "Begging of line" },
    ["<C-e>"] = { "<End>", "End of line" },

    -- navigate within insert mode
    ["<C-h>"] = { "<Left>", "Move left" },
    ["<C-l>"] = { "<Right>", "Move right" },
    ["<C-j>"] = { "<Down>", "Move down" },
    ["<C-k>"] = { "<Up>", "Move up" },
  },

  n = {},

  t = {},

  v = {},

  x = {},
}

M.comment = {}

M.lspconfig = {}

M.neo_tree = {}

M.telescope = {}

M.which_key = {}

M.blankline = {
  plugin = true,
}

M.gitsigns = {
  plugin = true,
}

return M
