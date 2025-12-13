local M = {}

local bindings = require("notes.bindings")
local spinner = require("notes.spinner")
local state = {
	win_main = nil,
	win_left = nil,
	win_right = nil,
	left_buf = nil,
}


M.setup = function()
	vim.api.nvim_create_user_command("Notes", function()
		M.open_notes()
	end, {})
end

local function today_filename()
	return os.date("%Y-%m-%d") .. ".md"
end

local function today_template()
	local date = os.date("%B %d, %Y")
	return {
		"# " .. date,
		"",
		"## Yesterday",
		"- ",
		"",
		"## Today",
		"- ",
	}
end

local function create_left_footer(width, footer_height, panel_height, row, col)
	local buf = vim.api.nvim_create_buf(false, true)

	local win = vim.api.nvim_open_win(buf, false, {
		relative = "editor",
		row = row + panel_height, -- place it under the left panel
		col = col,
		width = width,
		height = footer_height, -- correct height
		focusable = false,
		noautocmd = true,
		zindex = 50,
		border = "rounded",
		style = "minimal",
	})

	return buf, win
end

local function create_left_panel(width, height, row, col)
	local buf = vim.api.nvim_create_buf(false, true)

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		row = row,
		col = col,
		width = width,
		height = height,
		focusable = true,
		border = "rounded",
		style = "minimal",
	})

	return buf, win
end

local function create_right_panel(left_width, height, row, col)
	local buf = vim.api.nvim_create_buf(false, false)

	local win = vim.api.nvim_open_win(buf, false, {
		relative = "editor",
		row = row,
		col = col + left_width + 2,
		width = math.floor(left_width * 3), -- ~75% width
		height = height,
		focusable = true,
		border = "rounded",
		style = "minimal",
	})

	return buf, win
end

local function list_files()
	local dir = vim.g.notes_dir
	return vim.fn.systemlist("ls " .. dir)
end

function M.open_notes()
	local total_width            = math.floor(vim.o.columns * 0.8)
	local total_height           = math.floor(vim.o.lines * 0.8)
	local row                    = math.floor((vim.o.lines - total_height) / 2) - 2
	local col                    = math.floor((vim.o.columns - total_width) / 2)
	local left_width             = math.floor(total_width * 0.25)
	local panel_row              = row + 1
	local footer                 = {
		"   shortcuts:",
		"   Enter      open note",
		"   n          new note",
		"   d          delete note",
		"   q          quit",
		"   C-w w      focus left",
		"   C-w W      focus right",
	}
	local footer_height          = #footer

	-- We subtract footer AND the new header row for animation
	local left_panel_height      = total_height - footer_height - 1

	-- LEFT PANEL (shifted down by 1 to make room for header)
	local left_buf, left_win     =
	    create_left_panel(left_width, left_panel_height - 1, panel_row, col)
	state.left_buf               = left_buf
	state.win_left               = left_win

	-- FOOTER stays the same
	local footer_buf, footer_win =
	    create_left_footer(left_width, footer_height, left_panel_height + 1, panel_row, col)
	state.footer_buf             = footer_buf
	state.footer_win             = footer_win

	-- RIGHT PANEL stays aligned with left panel
	local right_buf, right_win   =
	    create_right_panel(left_width, total_height, row + 1, col)
	state.win_right              = right_win

	-- Populate left panel
	local files                  = list_files()
	vim.api.nvim_buf_set_lines(left_buf, 0, -1, false, files)
	vim.bo[left_buf].modifiable = false

	-- Populate footer
	vim.api.nvim_buf_set_lines(footer_buf, 0, -1, false, footer)
	vim.bo[footer_buf].modifiable = false

	-- Enter = open file
	vim.keymap.set("n", "<CR>", function()
		local line = vim.fn.getline(".")
		M.open_file(line)
	end, { buffer = left_buf })

	-- Bindings
	bindings.bind_close(left_buf)
	bindings.bind_close(right_buf)
	bindings.bind_navigation(state)
	bindings.bind_new_note(left_buf, state)
	bindings.bind_delete(left_buf, state)

	-- Auto-create today's note
	local today = today_filename()
	local full = vim.fn.expand(vim.g.notes_dir .. "/" .. today)

	if vim.fn.filereadable(full) == 0 then
		local f = io.open(full, "w")
		for _, line in ipairs(today_template()) do
			f:write(line .. "\n")
		end
		f:close()
	end

	-- Refresh left list
	local files = list_files()
	vim.bo[state.left_buf].modifiable = true
	vim.api.nvim_buf_set_lines(state.left_buf, 0, -1, false, files)
	vim.bo[state.left_buf].modifiable = false

	-- Automatically open today's note
	M.open_file(today)
end

function M.open_file(filename)
	if not filename or filename == "" then return end

	local full = vim.fn.expand(vim.g.notes_dir .. "/" .. filename)

	-- move focus to the right pane
	vim.api.nvim_set_current_win(state.win_right)

	-- open the file normally
	vim.cmd("edit " .. full)
end

function M.close_notes()
	if state.win_left and vim.api.nvim_win_is_valid(state.win_left) then
		vim.api.nvim_win_close(state.win_left, true)
	end
	if state.win_right and vim.api.nvim_win_is_valid(state.win_right) then
		vim.api.nvim_win_close(state.win_right, true)
	end
	if state.win_main and vim.api.nvim_win_is_valid(state.win_main) then
		vim.api.nvim_win_close(state.win_main, true)
	end
end

function M.new_note()
	-- prompt user
	local filename = vim.fn.input("New note name: ")

	if filename == nil or filename == "" then
		print("Cancelled")
		return
	end

	-- ensure extension (optional)
	if not filename:match("%.md$") then
		filename = filename .. ".md"
	end

	local full = vim.fn.expand(vim.g.notes_dir .. "/" .. filename)

	-- create empty file
	local f = io.open(full, "w")
	f:write("") -- optional
	f:close()

	-- refresh file list
	local files = list_files()

	-- temporarily allow edits
	vim.bo[state.left_buf].modifiable = true
	vim.api.nvim_buf_set_lines(state.left_buf, 0, -1, false, files)
	vim.bo[state.left_buf].modifiable = false

	-- open the new file
	M.open_file(filename)
end

function M.delete_note()
	local filename = vim.fn.getline(".")

	if not filename or filename == "" then
		print("No file selected")
		return
	end

	local full = vim.fn.expand(vim.g.notes_dir .. "/" .. filename)

	-- Confirm delete
	local confirm = vim.fn.input("Delete " .. filename .. "? (y/N): ")
	if confirm:lower() ~= "y" then
		print("Cancelled")
		return
	end

	-- Delete file
	os.remove(full)

	-- Refresh file list
	local files = list_files()
	vim.bo[state.left_buf].modifiable = true
	vim.api.nvim_buf_set_lines(state.left_buf, 0, -1, false, files)
	vim.bo[state.left_buf].modifiable = false

	print("Deleted:", filename)
end

return M
