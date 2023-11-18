local M = {}

---@class SmartTabConfig
---@field skips (string|fun(node_type: string):boolean)[]
---@field mapping string|boolean
---@field exclude_filetype string[]
local configs = {
    skips = { "string_content" },
    mapping = "<tab>",
    exclude_filetype = {},
}

local function is_blank_line()
    local line, _col = unpack(vim.api.nvim_win_get_cursor(0))
    return vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:match("%S") == nil
end

---@param node_type string
local function should_skip(node_type)
    for _, skip in ipairs(configs.skips) do
        if type(skip) == "string" and skip == node_type then
            return true
        elseif type(skip) == "function" and skip(node_type) then
            return true
        end
    end
    return false
end

---smart tab
---
---returns false if TS not available/parent doesn't exist
---@return boolean
function M.smart_tab()
    local node_ok, node = pcall(vim.treesitter.get_node)
    if not node_ok then
        -- TS not available
        vim.notify("TS not")
        return false
    end
    while node and should_skip(node:type()) do
        node = node:parent()
    end
    if not node then
        -- parent node doesn't exist
        vim.notify("parent not")
        return false
    end
    local row, col = node:end_()
    local ok = pcall(vim.api.nvim_win_set_cursor, 0, { row + 1, col })
    if not ok then
        ok = pcall(vim.api.nvim_win_set_cursor, 0, { row, col })
    end
    return ok
end

local function setup_keymap(filetype, buffer)
    if vim.tbl_contains(configs.exclude_filetype, filetype) then
        return
    end
    local mapping = configs.mapping--[[@as string]]
    vim.keymap.set("i", mapping, function()
        if is_blank_line() or not M.smart_tab() then
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(mapping, true, true, true), "n", true)
        end
    end, {
        buffer = buffer,
        desc = "smart-tab",
    })
end

---setup smart-tab plugin
---@param opts? SmartTabConfig
function M.setup(opts)
    opts = opts or {}
    configs = vim.tbl_extend("force", configs, opts)
    if configs.mapping then
        vim.api.nvim_create_autocmd("FileType", {
            callback = function(event)
                setup_keymap(event.match, event.buf)
            end,
        })
        -- load `setup_keymap` manually to work with lazy-loading
        local buffer = vim.api.nvim_get_current_buf()
        setup_keymap(vim.bo.filetype, buffer)
    end
end

return M
