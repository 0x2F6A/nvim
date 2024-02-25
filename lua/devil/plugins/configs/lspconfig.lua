local M = {}
local utils = require("devil.core.utils")
local lspconfig = require("lspconfig")
local lsp_util = require("lspconfig.util")

require("mason-lspconfig").setup({
  automatic_installation = false,
  ensure_installed = { "clangd", "gopls", "lua_ls", "rust_analyzer", "tsserver", "zls" },
})

-- local mason_registry = require("mason-registry")
-- local tsserver_path = mason_registry.get_package("typescript-language-server"):get_install_path()

local merge_tb = vim.tbl_deep_extend
local inlay_hint = vim.lsp.inlay_hint

function M.set_inlay_hints(client, bufnr)
  if not client then
    vim.notify_once("LSP inlay hints attached failed: nil client.", vim.log.levels.ERROR)
    return
  end

  if client.name == "zls" then
    vim.g.zig_fmt_autosave = 1
  end

  if client.supports_method("textDocument/inlayHint") or client.server_capabilities.inlayHintProvider then
    inlay_hint.enable(bufnr, true)
  end
end

function M.on_attach(client, bufnr)
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false

  require("lsp_signature").on_attach({
    bind = true,
    handler_opts = {
      border = "single",
    },
  }, bufnr)

  M.set_inlay_hints(client, bufnr)

  utils.load_mappings("lspconfig", { buffer = bufnr })

  vim.api.nvim_set_option_value("formatexpr", "v:lua.require'conform'.formatexpr()", { buf = bufnr })
  vim.api.nvim_set_option_value("omnifunc", "v:lua.vim.lsp.omnifunc", { buf = bufnr })
  vim.api.nvim_set_option_value("tagfunc", "v:lua.vim.lsp.tagfunc", { buf = bufnr })
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()

M.capabilities.textDocument.completion.completionItem = {
  documentationFormat = { "markdown", "plaintext" },
  snippetSupport = true,
  preselectSupport = true,
  insertReplaceSupport = true,
  labelDetailsSupport = true,
  deprecatedSupport = true,
  commitCharactersSupport = true,
  tagSupport = { valueSet = { 1 } },
  resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  },
}

local default_config = function()
  return {
    on_attach = M.on_attach,
    capabilities = M.capabilities,
  }
end

local noconfig_servers = {
  "angularls",
  "bashls",
  "elixirls",
  "emmet_language_server",
  "html",
  "lemminx",
  "maksman",
  "neocmake",
  "nil_ls",
  "phpactor",
  "serve_d",
  "slint_lsp",
  "svelte",
  "taplo",
  "vala_ls",
  "volar",
  "vimls",
}

for _, server in pairs(noconfig_servers) do
  lspconfig[server].setup(default_config())
end

local runtime_path = vim.split(package.path, ";", {})
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/>/init.lua")

require("neodev").setup()
lspconfig.lua_ls.setup(merge_tb("force", default_config(), {
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
        path = runtime_path,
      },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = {
          [vim.fn.expand("$VIMRUNTIME/lua")] = true,
          [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
          [vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy"] = true,
        },
        maxPreload = 100000,
        preloadFileSize = 10000,
      },
      hint = {
        enable = true,
        arrayIndex = "Auto",
        await = true,
        paramName = "All",
        paramType = true,
        semicolon = "SameLine",
        setType = false,
      },
    },
  },
}))

local clangd_capabilities = M.capabilities
clangd_capabilities.offsetEncoding = { "utf-16" } ---@diagnostic disable-line
lspconfig.clangd.setup({
  on_attach = function(client, bufnr)
    require("clangd_extensions").setup()

    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false

    require("lsp_signature").on_attach({
      bind = true,
      handler_opts = {
        border = "single",
      },
    }, bufnr)

    M.set_inlay_hints(client, bufnr)

    utils.load_mappings("lspconfig", { buffer = bufnr })

    vim.api.nvim_set_option_value("formatexpr", "v:lua.require'conform'.formatexpr()", { buf = bufnr })
    vim.api.nvim_set_option_value("omnifunc", "v:lua.vim.lsp.omnifunc", { buf = bufnr })
    vim.api.nvim_set_option_value("tagfunc", "v:lua.vim.lsp.tagfunc", { buf = bufnr })
  end,
  capabilities = clangd_capabilities,

  settings = {
    clangd = {
      InlayHints = {
        Designators = true,
        Enabled = true,
        ParameterNames = true,
        DeducedTypes = true,
      },
      fallbackFlags = { "-std=c++20" },
    },
  },
})

lspconfig.gopls.setup(merge_tb("force", default_config(), {
  settings = {
    gopls = {
      experimentalPostfixCompletions = true,
      analyses = {
        shadow = true,
        fieldalignment = true,
        nilness = true,
        unusedparams = true,
        unusedwrite = true,
        useany = true,
      },
      gofumpt = true,
      hints = {
        rangeVariableTypes = true,
        parameterNames = true,
        constantValues = true,
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        functionTypeParameters = true,
      },
      codelenses = {
        gc_details = false,
        generate = true,
        regenerate_cgo = true,
        run_govulncheck = true,
        test = true,
        tidy = true,
        upgrade_dependency = true,
        vendor = true,
      },
      usePlaceholders = true,
      completeUnimported = true,
      staticcheck = true,
      directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
      semanticTokens = true,
    },
  },
}))

--[[
lspconfig.rust_analyzer.setup(merge_tb("force", default_config(), {
  settings = {
    rust_analyzer = {
      checkOnSave = {
        allFeatures = true,
        overrideCommand = {
          "cargo",
          "clippy",
          "--workspace",
          "--message-format=json",
          "--all-targets",
          "--all-features",
        },
      },
      cargo = {
        loadOutDirsFromCheck = true,
      },
      procMacro = {
        enable = true,
      },
      inlayHints = {
        bindingModeHints = {
          enable = false,
        },
        chainingHints = {
          enable = true,
        },
        closingBraceHints = {
          enable = true,
          minLines = 25,
        },
        closureReturnTypeHints = {
          enable = "never",
        },
        lifetimeElisionHints = {
          enable = "never",
          useParameterNames = false,
        },
        maxLength = 25,
        parameterHints = {
          enable = true,
        },
        reborrowHints = {
          enable = "never",
        },
        renderColons = true,
        typeHints = {
          enable = true,
          hideClosureInitialization = false,
          hideNamedConstructor = false,
        },
      },
    },
  },
}))
]]

vim.g.rustaceanvim = {
  server = {
    on_attach = M.on_attach,
    settings = {
      ["rust-analyzer"] = {
        checkOnSave = {
          allFeatures = true,
          overrideCommand = {
            "cargo",
            "clippy",
            "--workspace",
            "--message-format=json",
            "--all-targets",
            "--all-features",
          },
        },
        cargo = {
          loadOutDirsFromCheck = true,
        },
        procMacro = {
          enable = true,
        },
        inlayHints = {
          bindingModeHints = {
            enable = false,
          },
          chainingHints = {
            enable = true,
          },
          closingBraceHints = {
            enable = true,
            minLines = 25,
          },
          closureReturnTypeHints = {
            enable = "never",
          },
          lifetimeElisionHints = {
            enable = "never",
            useParameterNames = false,
          },
          maxLength = 25,
          parameterHints = {
            enable = true,
          },
          reborrowHints = {
            enable = "never",
          },
          renderColons = true,
          typeHints = {
            enable = true,
            hideClosureInitialization = false,
            hideNamedConstructor = false,
          },
        },
      },
    },
  },
}

lspconfig.zls.setup(merge_tb("force", default_config(), {
  settings = {
    zls = {
      enable_snippets = true,
      enable_argument_placeholders = true,
      enable_ast_check_diagnostics = true,
      enable_build_on_save = true,
      enable_autofix = false,
      semantic_tokens = "full",
      enable_inlay_hints = true,
      inlay_hints_show_variable_type_hints = true,
      inlay_hints_show_parameter_name = true,
      inlay_hints_show_builtin = true,
      inlay_hints_exclude_single_argument = true,
      inlay_hints_hide_redundant_param_names = false,
      inlay_hints_hide_redundant_param_names_last_token = false,
      warn_style = false,
      highlight_global_var_declarations = false,
      dangerous_comptime_experiments_do_not_enable = false,
      skip_std_references = false,
      prefer_ast_check_as_child_process = true,
      record_session = false,
      record_session_path = nil,
      replay_session_path = nil,
      builtin_path = nil,
      zig_lib_path = nil,
      zig_exe_path = nil,
      build_runner_path = nil,
      global_cache_path = nil,
      build_runner_global_cache_path = nil,
      completions_with_replace = true,
    },
  },
}))

--[[
lspconfig.tsserver.setup(merge_tb("force", default_config(), {
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayVariableTypeHintsWhenTypeMatchesName = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayVariableTypeHintsWhenTypeMatchesName = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
  },
}))
]]
require("typescript-tools").setup({
  on_attach = M.on_attach,
  settings = {
    -- spawn additional tsserver instance to calculate diagnostics on it
    separate_diagnostic_server = true,
    -- "change"|"insert_leave" determine when the client asks the server about diagnostic
    publish_diagnostic_on = "insert_leave",
    -- array of strings("fix_all"|"add_missing_imports"|"remove_unused"|
    -- "remove_unused_imports"|"organize_imports") -- or string "all"
    -- to include all supported code actions
    -- specify commands exposed as code_actions
    expose_as_code_action = {},
    -- specify a list of plugins to load by tsserver, e.g., for support `styled-components`
    -- (see 💅 `styled-components` support section)
    tsserver_plugins = {},
    -- this value is passed to: https://nodejs.org/api/cli.html#--max-old-space-sizesize-in-megabytes
    -- memory limit in megabytes or "auto"(basically no limit)
    tsserver_max_memory = "auto",
    -- described below
    tsserver_format_options = {
      -- allowIncompleteCompletions = false,
      -- allowRenameOfImportPath = false,
    },
    tsserver_file_preferences = {
      includeInlayParameterNameHints = "all",
      includeInlayParameterNameHintsWhenArgumentMatchesName = true,
      includeInlayFunctionParameterTypeHints = true,
      includeInlayVariableTypeHints = true,
      includeInlayVariableTypeHintsWhenTypeMatchesName = true,
      includeInlayPropertyDeclarationTypeHints = true,
      includeInlayFunctionLikeReturnTypeHints = true,
      includeInlayEnumMemberValueHints = true,
    },
    -- locale of all tsserver messages, supported locales you can find here:
    -- https://github.com/microsoft/TypeScript/blob/3c221fc086be52b19801f6e8d82596d04607ede6/src/compiler/utilitiesPublic.ts#L620
    tsserver_locale = "en",
    -- mirror of VSCode's `typescript.suggest.completeFunctionCalls`
    complete_function_calls = false,
    include_completions_with_insert_text = true,
    -- CodeLens
    -- WARNING: Experimental feature also in VSCode, because it might hit performance of server.
    -- possible values: ("off"|"all"|"implementations_only"|"references_only")
    code_lens = "off",
    -- by default code lenses are displayed on all referencable values and for some of you it can
    -- be too much this option reduce count of them by removing member references from lenses
    disable_member_code_lens = true,
    -- JSXCloseTag
    -- WARNING: it is disabled by default (maybe you configuration or distro already uses nvim-ts-autotag,
    -- that maybe have a conflict if enable this feature. )
    jsx_close_tag = {
      enable = false,
      filetypes = { "javascriptreact", "typescriptreact" },
    },
  },
})

lspconfig.eslint.setup(merge_tb("force", default_config(), {
  root_dir = function(fname)
    local root_file = lsp_util.insert_package_json({
      ".eslintrc",
      ".eslintrc.js",
      ".eslintrc.cjs",
      ".eslintrc.yaml",
      ".eslintrc.yml",
      ".eslintrc.json",
      "eslint.config.js",
      "eslint.config.mjs",
    }, "eslintConfig", fname)

    return lsp_util.root_pattern(unpack(root_file))(fname)
  end,
}))

lspconfig.jsonls.setup(merge_tb("force", default_config(), {
  settings = {
    json = {
      schemas = require("schemastore").json.schemas({
        ignore = {},
      }),
      validate = { enable = true },
      format = { enable = true },
    },
  },
}))

lspconfig.yamlls.setup(merge_tb("force", default_config(), {
  settings = {
    yaml = {
      schemaStore = {
        -- You must disable built-in schemaStore support if you want to use
        -- this plugin and its advanced options like `ignore`.
        enable = false,
        -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
        url = "",
      },
      schemas = require("schemastore").yaml.schemas(),
    },
  },
}))

lspconfig.pyright.setup(merge_tb("force", default_config(), {
  settings = {
    --[[
    pylsp = {
      plugins = {
        ruff = {
          enabled = true, -- Enable the plugin
          extendSelect = { "I" }, -- Rules that are additionally used by ruff
          extendIgnore = { "C90" }, -- Rules that are additionally ignored by ruff
          format = { "I" }, -- Rules that are marked as fixable by ruff that should be fixed when running textDocument/formatting
          severities = { ["D212"] = "I" }, -- Optional table of rules where a custom severity is desired
          unsafeFixes = false, -- Whether or not to offer unsafe fixes as code actions. Ignored with the "Fix All" action

          -- Rules that are ignored when a pyproject.toml or ruff.toml is present:
          lineLength = 100, -- Line length to pass to ruff checking and formatting
          exclude = { "__about__.py" }, -- Files to be excluded by ruff checking
          select = { "F" }, -- Rules to be enabled by ruff
          ignore = { "D210" }, -- Rules to be ignored by ruff
          perFileIgnores = { ["__init__.py"] = "CPY001" }, -- Rules that should be ignored for specific files
          preview = false, -- Whether to enable the preview style linting and formatting.
          targetVersion = "py311", -- The minimum python version to target (applies for both linting and formatting).
        },
        yapf = { enabled = false },
        mccabe = { enabled = false },
        pycodestyle = { enabled = false },
        pyflakes = { enabled = false },
      },
    },
    ]]
    python = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "openFilesOnly",
        useLibraryCodeForTypes = true,
      },
    },
  },
}))

return
