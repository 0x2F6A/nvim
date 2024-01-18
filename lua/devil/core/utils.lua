local M = {}
local merge_tb = vim.tbl_deep_extend

-- Auto install plugins by git
---@param path string
---@param repository string
---@param branch string
function M.bootstrap(path, repository, branch)
  if not vim.loop.fs_stat(path) then
    vim.notify(("Bootstarting %s is being installed, please wait..."):format(repository), vim.log.levels.INFO)
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      ("https://github.com/%s"):format(repository),
      ("--branch=%s"):format(branch),
      path,
    })
  end
  vim.opt.rtp:prepend(path)
end

-- Load mappings
function M.load_mappings(section, mapping_opt)
  vim.schedule(function()
    local function set_section_map(section_values)
      if section_values.plugin then
        return
      end

      section_values.plugin = nil

      for mode, mode_values in pairs(section_values) do
        local default_opts = merge_tb("force", { mode = mode }, mapping_opt or {})
        for keybind, mapping_info in pairs(mode_values) do
          -- merge default + user opts
          local opts = merge_tb("force", default_opts, mapping_info.opts or {})

          mapping_info.opts, opts.mode = nil, nil
          opts.desc = mapping_info[2]

          vim.keymap.set(mode, keybind, mapping_info[1], opts)
        end
      end
    end

    local mappings = require("devil.core.mappings")

    if type(section) == "string" then
      mappings[section]["plugin"] = nil
      mappings = { mappings[section] }
    end

    for _, sect in pairs(mappings) do
      set_section_map(sect)
    end
  end)
end

-- Lazy load plugins
---@param plugin string
function M.lazy_load(plugin)
  vim.api.nvim_create_autocmd({ "BufRead", "BufWinEnter", "BufNewFile" }, {
    group = vim.api.nvim_create_augroup("BeLazyOnFileOpen" .. plugin, {}),
    callback = function()
      local file = vim.fn.expand("%")
      local condition = file ~= "neo-tree filesystem [1]" and file ~= "[lazy]" and file ~= ""

      if condition then
        vim.api.nvim_del_augroup_by_name("BeLazyOnFileOpen" .. plugin)

        -- dont defer for treesitter as it will show slow highlighting
        -- This deferring only happens only when we do "nvim filename"
        if plugin ~= "nvim-treesitter" then
          vim.schedule(function()
            require("lazy").load({ plugins = plugin })

            if plugin == "nvim-lspconfig" or plugin == "neo-tree" then
              vim.cmd("silent! do FileType")
            end
          end, 0)
        else
          require("lazy").load({ plugins = plugin })
        end
      end
    end,
  })
end

-- A full icon for lsp label kinds
M.kind_icons = {
  Array = "󰅪 ",
  Boolean = " ",
  BreakStatement = "󰙧 ",
  Call = "󰃷 ",
  CaseStatement = "󱃙 ",
  Class = " ",
  Color = "󰏘 ",
  Constant = "󰏿 ",
  Constructor = " ",
  ContinueStatement = "→ ",
  Copilot = " ",
  Declaration = "󰙠 ",
  Delete = "󰩺 ",
  DoStatement = "󰑖 ",
  Enum = " ",
  EnumMember = " ",
  Event = " ",
  Field = " ",
  File = "󰈙 ",
  Folder = "󰉋 ",
  ForStatement = "󰑖 ",
  Function = "󰊕 ",
  H1Marker = "󰉫 ", -- Used by markdown treesitter parser
  H2Marker = "󰉬 ",
  H3Marker = "󰉭 ",
  H4Marker = "󰉮 ",
  H5Marker = "󰉯 ",
  H6Marker = "󰉰 ",
  Identifier = "󰀫 ",
  IfStatement = "󰇉 ",
  Interface = " ",
  Keyword = "󰌋 ",
  List = "󰅪 ",
  Log = "󰦪 ",
  Lsp = " ",
  Macro = "󰁌 ",
  MarkdownH1 = "󰉫 ", -- Used by builtin markdown source
  MarkdownH2 = "󰉬 ",
  MarkdownH3 = "󰉭 ",
  MarkdownH4 = "󰉮 ",
  MarkdownH5 = "󰉯 ",
  MarkdownH6 = "󰉰 ",
  Method = "󰆧 ",
  Module = "󰏗 ",
  Namespace = "󰌗 ",
  Null = "󰢤 ",
  Number = "󰎠 ",
  Object = "󰅩 ",
  Operator = "󰆕 ",
  Package = "󰆦 ",
  Pair = "󰅪 ",
  Property = " ",
  Reference = "󰦾 ",
  Regex = " ",
  Repeat = "󰑖 ",
  Scope = "󰅩 ",
  Snippet = "󰩫 ",
  Specifier = "󰦪 ",
  Statement = "󰅩 ",
  String = " ",
  Text = "󰉿 ",
  Unit = "󰑭 ",
  Value = "󰎠 ",
  Variable = " ",
  Struct = " ",
  TypeParameter = "󰊄 ",
}

M.exclude_ft = {
  "lazy",
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
}

local proxy_lsps = {
  ["null-ls"] = true,
  ["efm"] = true,
  ["emmet_language_server"] = true,
  ["emmet_ls"] = true,
  ["eslint"] = true,
  ["cssmodule_ls"] = true,
  ["golangci_lint_ls"] = true,
  ["ruff_lsp"] = true,
}
-- Determine whether the obtained LSP is a proxy LSP
---@param name string
---@return boolean
function M.not_proxy_lsp(name)
  return not proxy_lsps[name]
end

-- Format getted LSP name
---@param name string
---@return string
local function format_client_name(name)
  return ("[%s]"):format(name)
end

local non_proxy_clients = {}

-- Function to get current activated LSP name
---@return string
function M.get_lsp_info()
  local buf_ft = vim.api.nvim_get_option_value("filetype", { scope = "local" })

  local clients = vim.lsp.get_clients()
  if not clients then
    non_proxy_clients = {}
    clients = vim.lsp.get_clients()
  end

  local cached_client = non_proxy_clients[buf_ft]
  if cached_client then
    return format_client_name(cached_client.name)
  end

  for _, client in ipairs(clients) do
    if client.config["filetypes"] and vim.tbl_contains(client.config["filetypes"], buf_ft) then
      if M.not_proxy_lsp(client.name) then
        non_proxy_clients[buf_ft] = client
        return format_client_name(client.name)
      end
    end
  end

  return "No Active LSP"
end

return M
