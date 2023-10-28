local ts_utils = require("nvim-treesitter.ts_utils")

local skips = { "string_content" }
local function should_skip(node_type)
	for _, skip in ipairs(skips) do
		if type(skip) == "string" and skip == node_type then
			return true
		elseif type(skip) == "function" and skip(node_type) then
			return true
		end
	end
	return false
end
local function is_blank_line()
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col == 0 or vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:match("%S") == nil
end
local function plugin()
	local node = ts_utils.get_node_at_cursor()
	if is_blank_line() then
		return "<tab>"
	end
	while should_skip(node:type()) do
		node = node:parent()
	end
	local row, col = node:end_()
	vim.api.nvim_win_set_cursor(0, { row + 1, col })
end

vim.keymap.set("i", "<tab>", plugin, { expr = true })
