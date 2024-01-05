local M = {}

M.blankline = {
  exclude = {
    filetypes = {
      "null-ls-info",
      "dashboard",
      "packer",
      "terminal",
      "help",
      "log",
      "markdown",
      "TelescopePrompt",
      "mason",
      "mason-lspconfig",
      "lspinfo",
      "toggleterm",
      "text",
      "checkhealth",
      "man",
      "gitcommit",
      "TelescopePrompt",
      "TelescopeResults",
    },
    buftypes = {
      "terminal",
      "nofile",
      "quickfix",
      "prompt",
    },
  },
}

M.luasnip = function(opts)
  require("luasnip").config.set_config(opts)

  -- vscode format
  require("luasnip.loaders.from_vscode").lazy_load()
  require("luasnip.loaders.from_vscode").lazy_load({ paths = vim.g.vscode_snippets_path or "" })

  -- snipmate format
  require("luasnip.loaders.from_snipmate").load()
  require("luasnip.loaders.from_snipmate").lazy_load({ paths = vim.g.snipmate_snippets_path or "" })

  -- lua format
  require("luasnip.loaders.from_lua").load()
  require("luasnip.loaders.from_lua").lazy_load({ paths = vim.g.lua_snippets_path or "" })

  vim.api.nvim_create_autocmd("InsertLeave", {
    callback = function()
      if
        require("luasnip").session.current_nodes[vim.api.nvim_get_current_buf()]
        and not require("luasnip").session.jump_active
      then
        require("luasnip").unlink_current()
      end
    end,
  })
end

M.lspkind = {
  -- default: true
  -- with_text = true,
  -- defines how annotations are shown
  -- default: symbol
  -- options: 'text', 'text_symbol', 'symbol_text', 'symbol'
  mode = "symbol_text",
  -- default symbol map
  -- can be either 'default' (requires nerd-fonts font) or
  -- 'codicons' for codicon preset (requires vscode-codicons font)
  --
  -- default: 'default'
  preset = "default",
  -- override preset symbols
  --
  -- default: {}
  symbol_map = require("devil.core.utils").kind_icons,
}

M.gitsigns = {
  signs = {
    add = { text = "│" },
    change = { text = "│" },
    delete = { text = "󰍵" },
    topdelete = { text = "‾" },
    changedelete = { text = "~" },
    untracked = { text = "│" },
  },
  on_attach = function(bufnr)
    require("devil.core.utils").load_mappings("gitsigns", { buffer = bufnr })
  end,
}

return M
