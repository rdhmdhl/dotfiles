local M = {}

local spinner_frames = {
	"⠋", "⠙", "⠹", "⠸", "⠼",
	"⠴", "⠦", "⠧", "⠇", "⠏",
}

-- Start a spinner in a buffer
function M.start(buf)
	local timer = vim.loop.new_timer()
	local frame = 1

	timer:start(0, 120, vim.schedule_wrap(function()
		if not vim.api.nvim_buf_is_valid(buf) then
			timer:stop()
			timer:close()
			return
		end

		vim.api.nvim_buf_set_lines(buf, 0, 1, false, {
			" " .. spinner_frames[frame]
		})

		frame = (frame % #spinner_frames) + 1
	end))

	return timer
end

return M
