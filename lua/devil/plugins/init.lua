local status_ok, lazy = pcall(require, "lazy")
if not status_ok then
  vim.notify("lazy.nvim not found", vim.log.levels.ERROR)
  return
end

local utils = require("devil.core.utils")

local plugins = {
  "nvim-lua/plenary.nvim",
  "folke/lazy.nvim",

  {
    "navarasu/onedark.nvim",
    config = function()
      require("onedark").setup({ style = "darker" })
    end,
  },

  {
    "nvim-tree/nvim-web-devicons",
    opts = function()
      return {
        override = {
          zsh = {
            icon = "",
            color = "#428850",
            cterm_color = "65",
            name = "Zsh",
          },
        },
      }
    end,
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "UIEnter",
    init = function()
      utils.lazy_load("indent-blankline.nvim")
    end,
    opts = function()
      return require("devil.plugins.configs.others").blankline
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-refactor",
      "nvim-treesitter/nvim-treesitter-textobjects",
      "nvim-treesitter/nvim-tree-docs",
      "nvim-treesitter/playground",
      "windwp/nvim-ts-autotag",
      "RRethy/nvim-treesitter-endwise",
      "ziontee113/syntax-tree-surfer",
    },
    init = function()
      utils.lazy_load("nvim-treesitter")
    end,
    cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
    build = ":TSUpdate",
    opts = function()
      return require("devil.plugins.configs.treesitter")
    end,
  },

  {
    "williamboman/mason.nvim",
    event = "LSPAttach",
    dependencies = { "williamboman/mason-lspconfig.nvim" },
    cmd = { "Mason", "MasonInstall", "MasonInstallAll", "MasonUpdate" },
    opts = function()
      return require("devil.plugins.configs.mason")
    end,
    config = function(_, opts)
      require("mason").setup(opts)

      require("mason-lspconfig").setup({
        automatic_installation = false,
        ensure_installed = { "clangd", "gopls", "lua_ls", "rust_analyzer", "tsserver", "zls" },
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    init = function()
      require("devil.core.utils").lazy_load("nvim-lspconfig")
    end,
    config = function()
      require("devil.plugins.configs.lspconfig")
    end,
  },

  {
    "j-hui/fidget.nvim",
    opts = {
      display = {
        progress_icon = { pattern = "dots", period = 1 },
      },
    },
  },

  {
    "folke/neodev.nvim",
    ft = { "lua" },
    opts = {
      library = {
        enabled = true, -- when not enabled, neodev will not change any settings to the LSP server
        -- these settings will be used for your Neovim config directory
        runtime = true, -- runtime path
        types = true, -- full signature, docs and completion of vim.api, vim.treesitter, vim.lsp and others
        plugins = true, -- installed opt or start plugins in packpath
        -- you can also specify the list of plugins to make available as a workspace library
        -- plugins = { "nvim-treesitter", "plenary.nvim", "telescope.nvim" },
      },
      setup_jsonls = true, -- configures jsonls to provide completion for project specific .luarc.json files
      -- for your Neovim config directory, the config.library settings will be used as is
      -- for plugin directories (root_dirs having a /lua directory), config.library.plugins will be disabled
      -- for any other directory, config.library.enabled will be set to false
      override = function(root_dir, options) end, ---@diagnostic disable-line
      -- With lspconfig, Neodev will automatically setup your lua-language-server
      -- If you disable this, then you have to set {before_init=require("neodev.lsp").before_init}
      -- in your lsp start options
      lspconfig = true,
      -- much faster, but needs a recent built of lua-language-server
      -- needs lua-language-server >= 3.6.0
      pathStrict = true,
    },
  },

  {
    "stevearc/conform.nvim",
    opts = function()
      return require("devil.plugins.configs.conform")
    end,
  },

  {
    "onsails/lspkind.nvim",
    opts = function()
      return require("devil.plugins.configs.others").lspkind
    end,
    config = function(_, opts)
      require("lspkind").init(opts)
    end,
  },

  -- load luasnips + cmp related in insert mode only
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      {
        -- snippet plugin
        "L3MON4D3/LuaSnip",
        dependencies = "rafamadriz/friendly-snippets",
        opts = { history = true, updateevents = "TextChanged,TextChangedI" },
        config = function(_, opts)
          require("devil.plugins.configs.others").luasnip(opts)
        end,
      },

      -- autopairing of (){}[] etc
      {
        "windwp/nvim-autopairs",
        opts = {
          fast_wrap = {},
          disable_filetype = { "TelescopePrompt", "vim" },
        },
        config = function(_, opts)
          require("nvim-autopairs").setup(opts)

          -- setup cmp for autopairs
          local cmp_autopairs = require("nvim-autopairs.completion.cmp")
          require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end,
      },

      -- cmp sources plugins
      {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-calc",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/cmp-nvim-lsp-signature-help",
        "hrsh7th/cmp-nvim-lsp-document-symbol",
        "hrsh7th/cmp-nvim-lua",
        "hrsh7th/cmp-emoji",
        "FelipeLema/cmp-async-path",
        "saadparwaiz1/cmp_luasnip",
        "petertriho/cmp-git",
        "Dosx001/cmp-commit",
        "ray-x/cmp-treesitter",
        "David-Kunz/cmp-npm",
      },
    },
    opts = function()
      return require("devil.plugins.configs.cmp") ---@diagnostic disable-line
    end,
    config = function(_, opts)
      local cmp_plug = require("cmp")
      cmp_plug.setup(opts)

      ---@diagnostic disable-next-line
      cmp_plug.setup.cmdline({ "/", "?" }, {
        mapping = cmp_plug.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      ---@diagnostic disable-next-line
      cmp_plug.setup.cmdline("/", {
        sources = cmp_plug.config.sources({
          { name = "nvim_lsp_document_symbol" },
        }, {
          { name = "buffer" },
        }),
      })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
      ---@diagnostic disable-next-line
      cmp_plug.setup.cmdline(":", {
        mapping = cmp_plug.mapping.preset.cmdline(),
        sources = cmp_plug.config.sources({
          { name = "async_path" },
        }, {
          { name = "cmdline" },
        }),
      })

      ---@diagnostic disable-next-line
      cmp_plug.setup.filetype("gitcommit", {
        sources = cmp_plug.config.sources({
          -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
          { name = "git" },
        }, {
          { name = "buffer" },
        }, {
          { name = "commit" },
        }, {
          { name = "emoji" },
        }),
      })
    end,
  },

  {
    "lewis6991/gitsigns.nvim",
    ft = { "gitcommit", "diff" },
    init = function()
      -- load gitsigns only when a git file is opened
      vim.api.nvim_create_autocmd({ "BufRead" }, {
        group = vim.api.nvim_create_augroup("GitSignsLazyLoad", { clear = true }),
        callback = function()
          vim.fn.jobstart({ "git", "-C", vim.loop["cwd"](), "rev-parse" }, {
            on_exit = function(_, return_code)
              if return_code == 0 then
                vim.api.nvim_del_augroup_by_name("GitSignsLazyLoad")
                vim.schedule(function()
                  require("lazy").load({ plugins = { "gitsigns.nvim" } })
                end)
              end
            end,
          })
        end,
      })
    end,
    opts = function()
      return require("devil.plugins.configs.others").gitsigns
    end,
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    lazy = false,
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    init = function()
      utils.load_mappings("neo_tree")
    end,
    opts = function()
      return require("devil.plugins.configs.neo-tree")
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    opts = function()
      return require("devil.plugins.configs.lualine")
    end,
  },

  -- bufdelete.nvim
  -- Delete Neovim buffers without losing window layout
  { "famiu/bufdelete.nvim", lazy = true },
  -- bufferline.nvim
  -- A snazzy bufferline for Neovim
  {
    "akinsho/bufferline.nvim",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "famiu/bufdelete.nvim",
    },
    version = "v4.*",
    init = function()
      utils.load_mappings("bufferline")
    end,
    opts = function()
      return require("devil.plugins.configs.bufferline")
    end,
  },

  {
    "rcarriga/nvim-notify",
    opts = {
      stages = "slide",
      timeout = 5000,
      render = "default",
    },
    config = function(_, opts)
      require("notify").setup(opts)
      vim.notify = require("notify")
    end,
  },

  {
    "numToStr/Comment.nvim",
    keys = {
      { "gcc", mode = "n", desc = "Comment toggle current line" },
      { "gc", mode = { "n", "o" }, desc = "Comment toggle linewise" },
      { "gc", mode = "x", desc = "Comment toggle linewise (visual)" },
      { "gbc", mode = "n", desc = "Comment toggle current block" },
      { "gb", mode = { "n", "o" }, desc = "Comment toggle blockwise" },
      { "gb", mode = "x", desc = "Comment toggle blockwise (visual)" },
    },
    init = function()
      utils.load_mappings("comment")
    end,
  },

  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },

  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
  },

  {
    "nvim-telescope/telescope.nvim",
    lazy = false,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-lua/plenary.nvim",
      "LinArcX/telescope-env.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
      "nvim-telescope/telescope-file-browser.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-project.nvim",
      "debugloop/telescope-undo.nvim",
    },
    cmd = "Telescope",
    init = function()
      utils.load_mappings("telescope")
    end,
    opts = function()
      return require("devil.plugins.configs.telescope")
    end,
    config = function(_, opts)
      local telescope = require("telescope") ---@diagnostic disable-line
      telescope.setup(opts)

      -- load extensions
      for _, ext in ipairs(opts.extensions_list) do
        telescope.load_extension(ext)
      end
    end,
  },
  {
    "danielfalk/smart-open.nvim",
    lazy = true,
    branch = "0.2.x",
    dependencies = {
      "kkharji/sqlite.lua",
      -- Only required if using match_algorithm fzf
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      -- Optional.  If installed, native fzy will be used when match_algorithm is fzy
      { "nvim-telescope/telescope-fzy-native.nvim" },
    },
  },

  -- Only load whichkey after all the gui
  {
    "folke/which-key.nvim",
    keys = { "<leader>", "<c-r>", "<c-w>", '"', "'", "`", "c", "v", "g" },
    init = function()
      utils.load_mappings("whichkey")
    end,
    cmd = "WhichKey",
  },
}

local lazy_opts = require("devil.plugins.configs.lazy") ---@diagnostic disable-line

lazy.setup(plugins, lazy_opts)
