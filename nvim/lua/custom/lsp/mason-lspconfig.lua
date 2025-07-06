local mason = require 'mason'
local mason_lspconfig = require 'mason-lspconfig'

-- Setup Mason
mason.setup()

-- Setup Mason-LSPConfig
mason_lspconfig.setup {
  ensure_installed = { 'lua_ls', 'pyright', 'ruff', 'gopls', 'clangd', 'ts_ls', 'yamlls', 'terraformls' },
  automatic_installation = false,
  automatic_enable = false,
}

-- Setup your LSP servers with lspconfig
local lspconfig = require 'lspconfig'

local servers = {
  terraformls = {
    filetypes = { 'terraform', 'tf', 'hcl' },
  },
  gopls = {
    settings = {
      gopls = {
        analyses = {
          unusedparams = true,
          shadow = true,
        },
        staticcheck = true,
      },
    },
  },
  yamlls = {
    settings = {
      yaml = {
        schemas = {
          -- optional: provide JSON schema associations for YAML validation
          ['https://json.schemastore.org/github-workflow.json'] = '/.github/workflows/*',
          ['https://json.schemastore.org/github-action.json'] = '/.github/action.{yml,yaml}',
          -- add more schemas if needed
        },
        validate = true,
        hover = true,
        completion = true,
      },
    },
  },
  clangd = {},
  lua_ls = {
    settings = {
      Lua = {
        completion = {
          callSnippet = 'Replace',
        },
        -- diagnostics = { disable = { "missing-fields" } },
      },
    },
  },
  ruff = {
    on_attach = function(client, bufnr)
      -- Ensure Ruff provides formatting
      client.server_capabilities.documentFormattingProvider = true
      -- Add a no-op to silence the unused variable warning
      vim.notify('Attached to buffer: ' .. bufnr, vim.log.levels.DEBUG)
    end,
  },
  pyright = {
    settings = {
      python = {
        analysis = {
          -- ignore = { '*' }, -- Let Ruff handle linting/formatting
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
          diagnosticMode = 'openFilesOnly', -- or "workspace" if you want broader checks
        },
      },
    },
  },
  ts_ls = {
    filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    settings = {
      typescript = {
        inlayHints = {
          includeInlayParameterNameHints = 'all',
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
      },
      javascript = {
        inlayHints = {
          includeInlayParameterNameHints = 'all',
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
      },
    },
  },
}

for server, config in pairs(servers) do
  lspconfig[server].setup(config)
end
