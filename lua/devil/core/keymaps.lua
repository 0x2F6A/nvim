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

  n = {
    ["<Esc>"] = { "<cmd> noh <CR>", "Clear highlights" },
    -- switch between windows
    ["<C-h>"] = { "<C-w>h", "Window left" },
    ["<C-l>"] = { "<C-w>l", "Window right" },
    ["<C-j>"] = { "<C-w>j", "Window down" },
    ["<C-k>"] = { "<C-w>k", "Window up" },

    -- line numbers
    ["<leader>n"] = { "<cmd> set nu! <CR>", "Toggle line number" },
    ["<leader>rn"] = { "<cmd> set rnu! <CR>", "Toggle relative number" },

    -- Allow moving the cursor through wrapped lines with j, k, <Up> and <Down>
    -- http://www.reddit.com/r/vim/comments/2k4cbr/problem_with_gj_and_gk/
    -- empty mode is same as using <cmd> :map
    -- also don't use g[j|k] when in operator pending mode, so it doesn't alter d, y or c behaviour
    ["j"] = { 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', "Move down", opts = { expr = true } },
    ["k"] = { 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', "Move up", opts = { expr = true } },
    ["<Up>"] = { 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', "Move up", opts = { expr = true } },
    ["<Down>"] = { 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', "Move down", opts = { expr = true } },

    ["<leader>ff"] = {
      function()
        vim.lsp.buf.format({ async = true })
      end,
      "LSP formatting",
    },
  },

  t = {},

  v = {
    ["<Up>"] = { 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', "Move up", opts = { expr = true } },
    ["<Down>"] = { 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', "Move down", opts = { expr = true } },
    ["<"] = { "<gv", "Indent line" },
    [">"] = { ">gv", "Indent line" },
  },

  x = {},
}

M.comment = {
  plugin = true,

  -- toggle comment in both modes
  n = {
    ["<leader>/"] = {
      function()
        require("Comment.api").toggle.linewise.current()
      end,
      "Toggle comment",
    },
  },

  v = {
    ["<leader>/"] = {
      "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
      "Toggle comment",
    },
  },
}

M.lspconfig = {
  plugin = true,

  -- See `<cmd> :help vim.lsp.*` for documentation on any of the below functions

  n = {
    ["gD"] = {
      function()
        vim.lsp.buf.declaration()
      end,
      "LSP declaration",
    },

    ["gd"] = {
      function()
        vim.lsp.buf.definition()
      end,
      "LSP definition",
    },

    ["K"] = {
      function()
        vim.lsp.buf.hover()
      end,
      "LSP hover",
    },

    ["gi"] = {
      function()
        vim.lsp.buf.implementation()
      end,
      "LSP implementation",
    },

    ["<leader>ls"] = {
      function()
        vim.lsp.buf.signature_help()
      end,
      "LSP signature help",
    },

    ["<leader>D"] = {
      function()
        vim.lsp.buf.type_definition()
      end,
      "LSP definition type",
    },

    ["<leader>ra"] = {
      function()
        require("nvchad.renamer").open()
      end,
      "LSP rename",
    },

    ["<leader>ca"] = {
      function()
        vim.lsp.buf.code_action()
      end,
      "LSP code action",
    },

    ["gr"] = {
      function()
        vim.lsp.buf.references()
      end,
      "LSP references",
    },

    ["<leader>lf"] = {
      function()
        vim.diagnostic.open_float({ border = "rounded" })
      end,
      "Floating diagnostic",
    },

    ["[d"] = {
      function()
        vim.diagnostic.goto_prev({ float = { border = "rounded" } })
      end,
      "Goto prev",
    },

    ["]d"] = {
      function()
        vim.diagnostic.goto_next({ float = { border = "rounded" } })
      end,
      "Goto next",
    },

    ["<leader>q"] = {
      function()
        vim.diagnostic.setloclist()
      end,
      "Diagnostic setloclist",
    },

    ["<leader>wa"] = {
      function()
        vim.lsp.buf.add_workspace_folder()
      end,
      "Add workspace folder",
    },

    ["<leader>wr"] = {
      function()
        vim.lsp.buf.remove_workspace_folder()
      end,
      "Remove workspace folder",
    },

    ["<leader>wl"] = {
      function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end,
      "List workspace folders",
    },
  },

  v = {
    ["<leader>ca"] = {
      function()
        vim.lsp.buf.code_action()
      end,
      "LSP code action",
    },
  },
}

M.neo_tree = {
  n = {
    ["<A-m>"] = {
      "<cmd> Neotree toggle <CR>",
      "Toggle neotree",
    },
  },
}

M.bufferline = {}

M.telescope = {
  plugin = true,

  n = {
    -- find
    -- ["<leader>ff"] = { "<cmd> Telescope find_files <CR>", "Find files" },
    ["<leader>ff"] = {
      function()
        require("telescope").extensions.smart_open.smart_open()
      end,
      "Find files",
    },
    ["<leader>fa"] = { "<cmd> Telescope find_files follow=true no_ignore=true hidden=true <CR>", "Find all" },
    ["<leader>fw"] = { "<cmd> Telescope live_grep <CR>", "Live grep" },
    ["<leader>fb"] = { "<cmd> Telescope buffers <CR>", "Find buffers" },
    ["<leader>fh"] = { "<cmd> Telescope help_tags <CR>", "Help page" },
    ["<leader>fo"] = { "<cmd> Telescope oldfiles <CR>", "Find oldfiles" },
    ["<leader>fz"] = { "<cmd> Telescope current_buffer_fuzzy_find <CR>", "Find in current buffer" },
    ["<leader>fp"] = { "<cmd> Telescope project <CR>", "Find recently projects" },

    -- git
    ["<leader>cm"] = { "<cmd> Telescope git_commits <CR>", "Git commits" },
    ["<leader>gt"] = { "<cmd> Telescope git_status <CR>", "Git status" },

    -- pick a hidden term
    ["<leader>pt"] = { "<cmd> Telescope terms <CR>", "Pick hidden term" },

    ["<leader>ma"] = { "<cmd> Telescope marks <CR>", "telescope bookmarks" },
  },
}

M.whichkey = {
  plugin = true,

  n = {
    ["<leader>wK"] = {
      function()
        vim.cmd("WhichKey")
      end,
      "Which-key all keymaps",
    },
    ["<leader>wk"] = {
      function()
        local input = vim.fn.input("WhichKey: ")
        vim.cmd("WhichKey " .. input)
      end,
      "Which-key query lookup",
    },
  },
}

M.blankline = {
  plugin = true,
}

M.gitsigns = {
  plugin = true,

  n = {
    -- Navigation through hunks
    ["]c"] = {
      function()
        if vim.wo.diff then
          return "]c"
        end
        vim.schedule(function()
          require("gitsigns").next_hunk()
        end)
        return "<Ignore>"
      end,
      "Jump to next hunk",
      opts = { expr = true },
    },

    ["[c"] = {
      function()
        if vim.wo.diff then
          return "[c"
        end
        vim.schedule(function()
          require("gitsigns").prev_hunk()
        end)
        return "<Ignore>"
      end,
      "Jump to prev hunk",
      opts = { expr = true },
    },

    -- Actions
    ["<leader>rh"] = {
      function()
        require("gitsigns").reset_hunk()
      end,
      "Reset hunk",
    },

    ["<leader>ph"] = {
      function()
        require("gitsigns").preview_hunk()
      end,
      "Preview hunk",
    },

    ["<leader>gb"] = {
      function()
        package.loaded.gitsigns.blame_line()
      end,
      "Blame line",
    },

    ["<leader>td"] = {
      function()
        require("gitsigns").toggle_deleted()
      end,
      "Toggle deleted",
    },
  },
}

M.bufferline = {

  n = {
    ["<C-h>"] = { "<CMD>BufferLineCyclePrev<CR>", "Cycle previous buffer" },
    ["<C-l>"] = { "<CMD>BufferLineCycleNext<CR>", "Cycle next buffer" },
    ["<C-w>"] = { "<CMD>Bdelete!<CR>", "Delete buffer" },
    ["<A-<>"] = { "<CMD>BufferLineMovePrev<CR>", "Move buffer to previous" },
    ["<A->>"] = { "<CMD>BufferLineMoveNext<CR>", "Move buffer to next" },
    ["<A-1>"] = { "<CMD>BufferLineGoToBuffer 1<CR>", "Go to 1 buffer" },
    ["<A-2>"] = { "<CMD>BufferLineGoToBuffer 2<CR>", "Go to 2 buffer" },
    ["<A-3>"] = { "<CMD>BufferLineGoToBuffer 3<CR>", "Go to 3 buffer" },
    ["<A-4>"] = { "<CMD>BufferLineGoToBuffer 4<CR>", "Go to 4 buffer" },
    ["<A-5>"] = { "<CMD>BufferLineGoToBuffer 5<CR>", "Go to 5 buffer" },
    ["<A-6>"] = { "<CMD>BufferLineGoToBuffer 6<CR>", "Go to 6 buffer" },
    ["<A-7>"] = { "<CMD>BufferLineGoToBuffer 7<CR>", "Go to 7 buffer" },
    ["<A-8>"] = { "<CMD>BufferLineGoToBuffer 8<CR>", "Go to 8 buffer" },
    ["<A-9>"] = { "<CMD>BufferLineGoToBuffer 9<CR>", "Go to 9 buffer" },
    ["<A-0>"] = { "<CMD>BufferLineGoToBuffer -1<CR>", "Go to first buffer" },
    ["<A-p>"] = { "<CMD>BufferLineTogglePin<CR>", "Toggle pinned buffer" },
    ["<Space>bt"] = { "<Cmd>BufferLineSortByTabs<CR>", "Sory buffers by tabs" },
    ["<Space>bd"] = { "<Cmd>BufferLineSortByDirectory<CR>", "Sort buffers by directories" },
    ["<Space>be"] = { "<Cmd>BufferLineSortByExtension<CR>", "Sort buffers by extensions" },
    ["<leader>bh"] = { "<CMD>BufferLineCloseLeft<CR>", "Close left buffer" },
    ["<leader>bl"] = { "<CMD>BufferLineCloseRight<CR>", "Close right buffer" },
    ["<leader>bp"] = { "<CMD>BufferLinePick<CR>", "Pick buffer" },
    ["<leader>bo"] = { "<CMD>BufferLineCloseRight<CR><CMD>BufferLineCloseLeft<CR>", "Close other buffer" },
    ["<leader>bc"] = { "<CMD>BufferLinePickClose<CR>", "Close picked buffer" },
  },
}

return M
