local options = {
  ensure_installed = {
    "bash",
    "c",
    "cpp",
    "css",
    "dart",
    "go",
    "html",
    "java",
    "javascript",
    "json",
    "lua",
    "python",
    "rust",
    "ruby",
    "tsx",
    "typescript",
    "yaml",
  },

  highlight = {
    enable = true,
    use_languagetree = true,
  },

  indent = { enable = true },

  -- nvim-treesitter/nvim-tree-docs
  tree_docs = { enable = true },
  -- https://github.com/RRethy/nvim-treesitter-endwise
  endwise = { enable = true },
  -- http://github.com/windwp/nvim-ts-autotag
  autotag = {
    enable = true,
    enable_rename = true,
    enable_close = true,
    enable_close_on_slash = true,
  },
  -- nvim-treesitter/nvim-treesitter-refactor
  refactor = {
    highlight_Definitions = {
      enable = true,
      -- Set to false if you have an `updatetime` of ~100
      clear_on_cursor_move = true,
    },
    highlight_current_scope = { enable = true },
  },
  -- nvim-treesitter/nvim-treesitter-textobjects
  textobjects = {
    enable = true,
    select = {
      enable = true,

      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,

      keymaps = {
        -- You can use than capture groups defined in textobjects.scm
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["ai"] = "@conditional.outer",
        ["ii"] = "@conditional.inner",
        ["al"] = "@loop.outer",
        ["il"] = "@loop.inner",
        ["ab"] = "@block.outer",
        ["ib"] = "@block.inner",
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ["<leader>a"] = "@parameter.inner",
      },
      swap_previous = {
        ["<leader>A"] = "@parameter.inner",
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- weather to set jumps in the jumplist
      goto_next_start = {
        ["]m"] = "@function.outer",
        ["]]"] = "@class.outer",
      },
      goto_next_end = {
        ["]M"] = "@function.outer",
        ["]["] = "@class.outer",
      },
      goto_previous_start = {
        ["[m"] = "@function.outer",
        ["[["] = "@class.outer",
      },
      goto_previous_end = {
        ["[M"] = "@function.outer",
        ["[]"] = "@class.outer",
      },
    },
  },
}

return options
