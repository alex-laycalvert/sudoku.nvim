local M = {}

local buf = -1
local win = -1
local board = {
    { 0, 0, 0, 0, 0, 0, 0, 0, 0 },
    { 0, 0, 0, 0, 0, 0, 0, 0, 0 },
    { 0, 0, 0, 0, 0, 0, 0, 0, 0 },
    { 0, 0, 0, 0, 0, 0, 0, 0, 0 },
    { 0, 0, 0, 0, 0, 0, 0, 0, 0 },
    { 0, 0, 0, 0, 0, 0, 0, 0, 0 },
    { 0, 0, 0, 0, 0, 0, 0, 0, 0 },
    { 0, 0, 0, 0, 0, 0, 0, 0, 0 },
    { 0, 0, 0, 0, 0, 0, 0, 0, 0 },
}
local pos = {
    row = 0,
    col = 0,
}

local default_mappings = {
    r = 'reset()',
    q = 'close()',
    h = 'move_left()',
    j = 'move_down()',
    k = 'move_up()',
    l = 'move_right()',
    ['0'] = 'set_number(0)',
    ['1'] = 'set_number(1)',
    ['2'] = 'set_number(2)',
    ['3'] = 'set_number(3)',
    ['4'] = 'set_number(4)',
    ['5'] = 'set_number(5)',
    ['6'] = 'set_number(6)',
    ['7'] = 'set_number(7)',
    ['8'] = 'set_number(8)',
    ['9'] = 'set_number(9)',
}

local function set_mappings (mappings)
    for k, v in pairs(mappings) do
        vim.api.nvim_buf_set_keymap(
            buf, 'n', k, ':lua require("sudoku").' .. v .. '<CR>',
            { nowait = true, noremap = true, silent = true }
        )
    end
end

local function display_board ()
    local dboard = {}
    local current_index = 1
    for r_num, r in pairs(board) do
        local line = ''
        for c_num, c in pairs(r) do
            if c <= 0 then c = ' ' end
            line = line .. c
            if c_num % 3 == 0 and c_num ~= 9 then
                line = line .. '||'
            elseif c_num ~= 9 then
                line = line .. '  '
            end
        end
        dboard[current_index] = line
        if (current_index + 1) % 6 == 0 then
            dboard[current_index + 1] = '-------------------------'
        else
            dboard[current_index + 1] = ''
        end
        current_index = current_index + 2
    end
    return dboard
end

local function open_buffer ()
    buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
end

local function open_window ()
    if buf < 0 then open_buffer() end
    local gwidth = vim.api.nvim_list_uis()[1].width
    local gheight = vim.api.nvim_list_uis()[1].height
    local height = 17
    local width = 25
    local win_opts = {
        relative = 'editor',
        style = 'minimal',
        border = 'single',
        height = height,
        width = width,
        row = (gheight - height) * 0.5,
        col = (gwidth - width) * 0.5
    }
    win = vim.api.nvim_open_win(buf, true, win_opts)
    set_mappings(default_mappings)
end

local function update_view ()
    if win < 0 then open_window() end
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, display_board())
    vim.api.nvim_win_set_cursor(win, { pos.row * 2 - 1, 3 * pos.col - 3 })
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
end

M.move_up = function ()
    pos.row = pos.row - 1
    if pos.row <= 0 then pos.row = 9 end
    update_view()
end

M.move_down = function ()
    pos.row = pos.row + 1
    if pos.row > 9 then pos.row = 1 end
    update_view()
end

M.move_left = function ()
    pos.col = pos.col - 1
    if pos.col <= 0 then pos.col = 9 end
    update_view()
end

M.move_right = function ()
    pos.col = pos.col + 1
    if pos.col > 9 then pos.col = 1 end
    update_view()
end

M.set_number = function (number)
    board[pos.row][pos.col] = number
    update_view()
end

M.reset = function ()
    for r, row in pairs(board) do
        for c, col in pairs(row) do
            board[r][c] = 0
        end
    end
    update_view()
end

M.close = function ()
    vim.api.nvim_win_close(win, true)
    win = -1
    buf = -1
end

M.play = function ()
    print('Playing sudoku...')
    pos.row = 1
    pos.col = 1
    update_view()
end

return M
