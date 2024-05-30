local utils = require("devil.core.utils")
local lspconfig = require("lspconfig")
local lsp_util = require("lspconfig.util")

require("mason-lspconfig").setup({
  automatic_installation = false,
  ensure_installed = { "clangd", "gopls", "lua_ls", "rust_analyzer", "tsserver", "zls" },
})

-- local mason_registry = require("mason-registry")
-- local tsserver_path = mason_registry.get_package("typescript-language-server"):get_install_path()

-- local merge_tb = vim.tbl_deep_extend
local default_config = utils.default_config

local noconfig_servers = {
  "angularls",
  "bashls",
  "cssls",
  "cssmodules_ls",
  "elixirls",
  "emmet_language_server",
  "golangci_lint_ls",
  "html",
  "lemminx",
  "marksman",
  "neocmake",
  "nil_ls",
  "ruff_lsp",
  "serve_d",
  "slint_lsp",
  "solargraph",
  "standardrb",
  "svelte",
  "tailwindcss",
  "taplo",
  "vala_ls",
  "vimls",
}

for _, server in pairs(noconfig_servers) do
  lspconfig[server].setup(default_config())
end

-- clangd, clang official lsp. https://github.com/clangd/clangd
local clangd_capabilities = utils.capabilities
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

    utils.set_inlay_hints(client, bufnr)

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

-- lua-language-server(sumneko). https://github.com/LuaLS/lua-language-server
local runtime_path = vim.split(package.path, ";", {})
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/>/init.lua")

require("neodev").setup()
local lua_ls = {
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
}

-- gopls, golang official lsp. https://github.com/golang/tools/blob/master/gopls
local gopls = {
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
}

-- zls, zigtools provide's lsp. https://github.com/zigtools/zls
local zls = {
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
}

-- denols. deno official lsp. https://github.com/denoland/deno/blob/main/cli/lsp
local denols = {
  settings = {
    deno = {
      enable = true,
      suggest = {
        imports = {
          hosts = {
            ["https://deno.land"] = true,
          },
        },
      },
      inlayHints = {
        parameterNames = { enabled = "all", suppressWhenArgumentMatchesName = true },
        parameterTypes = { enabled = true },
        variableTypes = { enabled = true, suppressWhenTypeMatchesName = true },
        propertyDeclarationTypes = { enabled = true },
        functionLikeReturnTypes = { enable = true },
        enumMemberValues = { enabled = true },
      },
    },
  },
}

-- eslint. eslint official lsp. https://github.com/eslint/eslint
local eslint = {
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
}

-- jsonls, the popular json lsp. https://github.com/json-transformations/jsonls
local jsonls = {
  settings = {
    json = {
      schemas = require("schemastore").json.schemas({
        ignore = {},
      }),
      validate = { enable = true },
      format = { enable = true },
    },
  },
}

-- svelte-language-server, sveltejs official lsp. https://github.com/sveltejs/language-tools
local svelte = {
  settings = {
    typescript = {
      inlayHints = {
        parameterNames = { enabled = "all" },
        parameterTypes = { enabled = true },
        variableTypes = { enabled = true },
        propertyDeclarationTypes = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        enumMemberValues = { enabled = true },
      },
    },
  },
}

-- volar, vue.js official lsp. https://github.com/vuejs/language-tools
local volar = {
  settings = {
    vue = {
      inlayHints = {
        inlineHandlerLeading = true,
        missingProps = true,
        optionsWrapper = true,
        vBindShorthand = true,
      },
    },
  },
}

-- tailwindcss, tailwindcss's official lsp. https://github.com/tailwindlabs/tailwindcss-intellisense
local tailwindcss = {
  root_dir = function(fname)
    return lsp_util.root_pattern(
      "tailwind.config.js",
      "tailwind.config.cjs",
      "tailwind.config.mjs",
      "tailwind.config.ts",
      "postcss.config.js",
      "postcss.config.cjs",
      "postcss.config.mjs",
      "postcss.config.ts"
    )(fname) or lsp_util.find_git_ancestor(fname)
  end,
}

-- yaml-language-server, redhat provided lsp. https://github.com/redhat-developer/yaml-language-server
local yamlls = {
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
}

-- pyright, microsoft provided lsp. https://github.com/microsoft/pyright
local pyright = {
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "openFilesOnly",
        useLibraryCodeForTypes = true,
      },
    },
  },
}

-- phpactor, a open source PHP lsp. https://github.com/phpactor/phpactor
local phpactor = {
  init_options = {
    ["language_server_worse_reflection.inlay_hints.enable"] = true,
    ["language_server_worse_reflection.inlay_hints.types"] = true,
    ["language_server_worse_reflection.inlay_hints.params"] = true,
  },
}

-- csharp-language-server, a omnisharp lsp's replacement(roslyn-based). https://github.com/razzmatazz/csharp-language-server
local csharp_ls = {
  handlers = {
    ["textDocument/definition"] = require("csharpls_extended").handler,
    ["textDocument/typeDefinition"] = require("csharpls_extended").handler,
  },
  init_options = {
    AutomaticWorkspaceInit = true,
  },
}

-- kotlin-language-server, a community's kotlin lsp. https://github.com/fwcd/kotlin-language-server
local kotlin_language_server = {
  settings = {
    kotlin = {
      hints = {
        typeHints = true,
        parameterHints = true,
        chaineHints = true,
      },
    },
  },
}

local lsp_configs = {
  ["csharp_ls"] = csharp_ls,
  ["denols"] = denols,
  ["eslint"] = eslint,
  ["gopls"] = gopls,
  ["jsonls"] = jsonls,
  ["kotlin_language_server"] = kotlin_language_server,
  ["lua_ls"] = lua_ls,
  ["phpactor"] = phpactor,
  ["pyright"] = pyright,
  ["svelte"] = svelte,
  ["tailwindcss"] = tailwindcss,
  ["volar"] = volar,
  ["yamlls"] = yamlls,
  ["zls"] = zls,
}

for lsp_name, lsp_config in pairs(lsp_configs) do
  utils.setup_custom_settings(lsp_name, lsp_config)
end

-- ************************************************************************************************
--[[
lspconfig.omnisharp.setup(merge_tb("force", default_config(), {
  handlers = {
    ["textDocument/definition"] = require("omnisharp_extended").handler,
  },
}))
]]

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
