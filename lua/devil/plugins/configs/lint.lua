local lint = require("lint")

lint.linters_by_ft = {
  c = { "clangtidy" },
  cpp = { "clangtidy" },
  css = { "stylelint" },
  lua = { "selene" },
  go = { "golangcilint" },
  javascript = { "eslint" },
  javascriptreact = { "eslint" },
  typescript = { "eslint" },
  typescriptreact = { "eslint" },
  python = { "ruff" },
  vim = { "vint" },
}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  desc = "Lint code on write post",
  callback = function()
    require("lint").try_lint()
  end,
})
