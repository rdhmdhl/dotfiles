local M = {}

M.setup = function(opts)
	vim.g.notes_dir = opts.notes_dir or vim.fn.expand("~/notes")
	require("notes.ui").setup()
end

return M
