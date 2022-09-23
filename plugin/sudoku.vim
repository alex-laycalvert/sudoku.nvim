if exists("g:loaded_sudoku_plugin")
    finish
endif
let g:loaded_sudoku_plugin = 1

command! -nargs=0 Sudoku lua require('sudoku').play()
