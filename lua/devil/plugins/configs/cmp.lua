local cmp = require("cmp")
local luasnip = require("luasnip")
local kind_icons = require("devil.core.utils").kind_icons

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local cmp_ui = {
  icons = true,
  lspkind_text = true,
  style = "default",
  border_color = "grey_fg",
  selected_item_bg = "colored",
}
local cmp_style = cmp_ui.style

local formatting_style = {
  fields = {
    cmp.ItemField.Abbr,
    cmp.ItemField.Kind,
    cmp.ItemField.Menu,
  },
  format = require("lspkind").cmp_format({
    mode = "symbol_text",

    maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
    -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
    ellipsis_char = "...",

    -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
    -- The function below will be called before any actual modifications from lspkind
    -- so that you can provide more controls on popup customization.
    -- (See [#30](https://github.com/onsails/lspkind.nvim/pull/30))
    before = function(entry, vim_item)
      local shorten_abbr = string.sub(vim_item.abbr, 1, 30)
      if shorten_abbr ~= vim_item.abbr then
        vim_item.abbr = ("%s..."):format(shorten_abbr)
      end
      -- Kind icons
      vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind], vim_item.kind)
      -- Source
      vim_item.menu = ({
        buffer = "[Buf]",
        nvim_lsp = "[LSP]",
        luasnip = "[LuaSnip]",
        nvim_lua = "[API]",
        latex_symbols = "[LaTeX]",
        path = "[Path]",
        emoji = "[Emoji]",
        treesitter = "[TreeSitter]",
        crates = "[Crates]",
        npm = "[NPM]",
        cmdline = "[CMD]",
        git = "[Git]",
        calc = "[Calc]",
      })[entry.source.name]
      return vim_item
    end,
  }),
}

local cmp_mapping = {
  -- completion appears
  ["<A-.>"] = cmp.mapping(cmp.mapping.completion, { "i", "c" }),
  -- cancel
  ["<A-,>"] = cmp.mapping({
    i = cmp.mapping.abort(),
    c = cmp.mapping.close(),
  }),

  -- confirm
  -- Accept surrently selected item. If none slected, `select` first item
  -- Set `select` to `fasle` to only confirm explicitly slected items
  ["<CR>"] = cmp.mapping.confirm({
    select = true,
    behavior = cmp.ConfirmBehavior.Replace,
  }),
  -- can scroll if too many items
  ["<C-u>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
  ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),

  -- previous
  ["<C-k>"] = cmp.mapping.select_prev_item(),
  -- next
  ["<C-j>"] = cmp.mapping.select_next_item(),
  ["<Tab>"] = cmp.mapping(function(fallback)
    if cmp.visible() then
      cmp.select_next_item()
      -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
      -- that way you will only jump inside the snippet region
    elseif luasnip.expand_or_jumpable() then
      luasnip.expand_or_jump()
    elseif has_words_before() then
      cmp.complete()
    else
      fallback()
    end
  end, { "i", "s" }),

  ["<S-Tab>"] = cmp.mapping(function(fallback)
    if cmp.visible() then
      cmp.select_prev_item()
    elseif luasnip.jumpable(-1) then
      luasnip.jump(-1)
    else
      fallback()
    end
  end, { "i", "s" }),
}

local function under(entry1, entry2)
  local _, entry1_under = entry1.completion_item.label:find("^_+")
  local _, entry2_under = entry2.completion_item.label:find("^_+")
  entry1_under = entry1_under or 0
  entry2_under = entry2_under or 0
  if entry1_under > entry2_under then
    return false
  elseif entry1_under < entry2_under then
    return true
  end
end

local function border(hl_name)
  return {
    { "╭", hl_name },
    { "─", hl_name },
    { "╮", hl_name },
    { "│", hl_name },
    { "╯", hl_name },
    { "─", hl_name },
    { "╰", hl_name },
    { "│", hl_name },
  }
end

local options = {
  completion = {
    completeopt = "menu,menuone",
  },

  window = {
    completion = {
      side_padding = (cmp_style ~= "atom" and cmp_style ~= "atom_colored") and 1 or 0,
      winhighlight = "Normal:CmpPmenu,CursorLine:CmpSel,Search:None",
      scrollbar = true,
    },
    documentation = {
      border = border("CmpDocBorder"),
      winhighlight = "Normal:CmpDoc",
    },
  },
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },

  formatting = formatting_style,

  mapping = cmp_mapping,

  sources = cmp.config.sources({
    {
      name = "nvim_lsp",
      entry_filter = function(entry, ctx)
        local kind = require("cmp.types.lsp").CompletionItemKind[entry:get_kind()]
        if kind == "Snippet" and ctx.prev_context.filetype == "java" then
          return false
        end
        return true
      end,
    },
    { name = "luasnip", option = { use_show_condition = false } },
    { name = "nvim_lua" },
    { name = "buffer", keywords = 3 },
    { name = "async_path" },
    { name = "calc" },
    { name = "treesitter" },
    -- { name = "crates" },
    -- { name = "npm", keyword_length = 4 },
  }),
  sorting = {
    comparators = {
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.score,
      under,
      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },
  },
}

if cmp_style ~= "atom" and cmp_style ~= "atom_colored" then
  options.window.completion.border = border("CmpBorder")
end

cmp.setup(options)

---@diagnostic disable-next-line
cmp.setup.cmdline({ "/", "?" }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = "buffer" },
  },
})

---@diagnostic disable-next-line
cmp.setup.cmdline("/", {
  sources = cmp.config.sources({
    { name = "nvim_lsp_document_symbol" },
  }, {
    { name = "buffer" },
  }),
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
---@diagnostic disable-next-line
cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = "async_path" },
  }, {
    { name = "cmdline" },
  }),
})

---@diagnostic disable-next-line
cmp.setup.filetype("gitcommit", {
  sources = cmp.config.sources({
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
