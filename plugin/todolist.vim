" MIT License
"
" Modified by the author.
"
" Copyright (c) 2022 miyakogi (https://github.com/miyakogi)
"
" ========================= License of Original Work =========================
"
" MIT License
"
" Copyright (c) 2020 Alexander Serebryakov (alex.serebr@gmail.com)
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to
" deal in the Software without restriction, including without limitation the
" rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
" sell copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
" FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
" IN THE SOFTWARE.


"Plugin startup code
if !exists('g:todolist_plugin')
  let g:todolist_plugin = 1

  if exists('vimtodolists_auto_commands')
    echoerr 'todo-list.nvim: todolist_auto_commands group already exists'
    exit
  endif

  "Defining auto commands
  augroup todolist_auto_commands
    autocmd!
    autocmd BufRead,BufNewFile *.todo.md call todolist#init()
    " autocmd FileType todo call todolist#init()
  augroup end

  "Defining plugin commands
  command! TodoListCreateNewItemBelow silent call todolist#create_new_item_below()
  command! TodoListCreateNewItemAbove silent call todolist#create_new_item_above()
  command! TodoListCreateNewItem silent call todolist#create_new_item()
endif
