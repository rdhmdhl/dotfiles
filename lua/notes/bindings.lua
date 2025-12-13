local M = {}

function M.bind_delete(left_buf, state)
	vim.keymap.set("n", "d", function()
		require("notes.ui").delete_note()
	end, { buffer = left_buf })
end

function M.bind_new_note(buf, state)
	vim.keymap.set("n", "n", function()
		require("notes.ui").new_note()
	end, { buffer = buf })
end

function M.bind_navigation(state)
	local opts = { silent = true, noremap = true }

	-- Focus left window
	vim.keymap.set("n", "<A-h>", function()
		if state.win_left and vim.api.nvim_win_is_valid(state.win_left) then
			vim.api.nvim_set_current_win(state.win_left)
		end
	end, opts)

	-- Focus right window
	vim.keymap.set("n", "<A-l>", function()
		if state.win_right and vim.api.nvim_win_is_valid(state.win_right) then
			vim.api.nvim_set_current_win(state.win_right)
		end
	end, opts)

	-- Close notes UI
	vim.keymap.set("n", "q", function()
		require("notes.ui").close_notes()
	end, opts)
end

function M.bind_close(buf)
	vim.keymap.set("n", "q", function()
		require("notes.ui").close_notes()
	end, { buffer = buf, nowait = true })
end

return M
