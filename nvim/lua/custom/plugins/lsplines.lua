return {
  'maan2003/lsp_lines.nvim',
  config = function()
    require('lsp_lines').setup()
    vim.diagnostic.config {
      virtual_text = true, -- disable inline diagnostics
      virtual_lines = false, -- enable virtual lines (the wrapped ones)
    }
  end,
}
