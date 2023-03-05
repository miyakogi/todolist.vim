" Copyright (c) 2022 miyakogi (https://github.com/miyakogi)
"
" Original Work License ------------------------------------------------------
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

" Initializes plugin settings and mappings
function! todolist#init()
  setlocal tabstop=2
  setlocal shiftwidth=2
  setlocal expandtab
  setlocal cursorline

  call todolist#initialize_tokens()
  call todolist#initialize_syntax()

  " set keymap
  call todolist#set_item_mode()
endfunction

" Initializes done/undone tokens
function! todolist#initialize_tokens()
  let g:todolist#escaped = '*[]'

  if !exists('g:todolist#undone_item')
    let g:todolist#undone_item = '- [ ]'
  endif

  if !exists('g:todolist#done_item')
    let g:todolist#done_item = '- [x]'
  endif

  let g:todolist#done_item_escaped = escape(g:todolist#done_item, g:todolist#escaped)
  let g:todolist#undone_item_escaped = escape(g:todolist#undone_item, g:todolist#escaped)
endfunction

" Initiaizes syntax
function! todolist#initialize_syntax()
  execute('syntax match TodoListDone "\v^\s*' . g:todolist#done_item_escaped . '\s*"')
  execute('syntax match TodoListNormal "\v^\s*' . g:todolist#undone_item_escaped . '\s*"')

  highlight link TodoListDone Comment
  highlight link TodoListNormal Normal
endfunction

" Sets the item done
function! todolist#set_item_done(lineno)
  let l:line = getline(a:lineno)
  call setline(a:lineno, substitute(l:line, '^\(\s*\)' . g:todolist#undone_item_escaped, '\1' . g:todolist#done_item_escaped, ''))
endfunction

" Sets the item not done
function! todolist#set_item_not_done(lineno)
  let l:line = getline(a:lineno)
  call setline(a:lineno, substitute(l:line, '^\(\s*\)' . g:todolist#done_item_escaped, '\1' . g:todolist#undone_item_escaped, ''))
endfunction

" Checks that line is a todo list item
function! todolist#line_is_item(line)
  if match(a:line, '^\s*\(' . g:todolist#done_item_escaped . '\|' . g:todolist#undone_item_escaped . '\).*') != -1
    return 1
  endif

  return 0
endfunction

" Checks that item is not done
function! todolist#item_is_not_done(line)
  if match(a:line, '^\s*' . g:todolist#undone_item_escaped . '.*') != -1
    return 1
  endif

  return 0
endfunction

" Checks that item is done
function! todolist#item_is_done(line)
  if match(a:line, '^\s*' . g:todolist#done_item_escaped . '.*') != -1
    return 1
  endif

  return 0
endfunction


" ========== Key Mapping ==========
" Sets mapping for normal navigation and editing mode
function! todolist#set_normal_mode()
  nunmap <buffer> o
  nunmap <buffer> O
  nunmap <buffer> j
  nunmap <buffer> k
  inoremap <buffer><silent> <C-l> <C-r>=todolist#create_new_item()<CR>
  nnoremap <buffer><silent> s :call todolist#toggle_item()<CR>
  noremap <buffer><silent> <leader>e :silent call todolist#set_item_mode()<CR>
endfunction


" Sets mappings for faster item navigation and editing
function! todolist#set_item_mode_default()
  nnoremap <buffer><silent> o :call todolist#create_new_item_below()<CR>
  nnoremap <buffer><silent> O :call todolist#create_new_item_above()<CR>
  inoremap <buffer><silent> <C-l> <C-r>=todolist#create_new_item()<CR>
  nnoremap <buffer><silent> j :call todolist#go_to_next_item()<CR>
  nnoremap <buffer><silent> k :call todolist#go_to_prev_item()<CR>
  nnoremap <buffer><silent> s :call todolist#toggle_item()<CR>
  noremap <buffer><silent> <leader>e :silent call todolist#set_normal_mode()<CR>
endfunction

function! todolist#set_item_mode()
  if exists('g:todolist#custom_keymapper')
    try
      call call(g:todolist#custom_keymapper, [])
    catch
      echo 'todolist.nvim: Error in custom key mapper.'
           \.' Falling back to default mappings'
      call todolist#set_item_mode_default()
    endtry
  else
    call todolist#set_item_mode_default()
  endif
endfunction

" Creates a new item to the current line
function! todolist#create_new_item()
  let l:line = getline('.')
  let l:linenr = line('.')
  let l:col = col('.')

  if match(l:line, '\v^\s*(' . g:todolist#undone_item_escaped . '|' . g:todolist#done_item_escaped . ')') == -1
    let l:text = g:todolist#undone_item . " "
    execute 'normal! I' . l:text
    let l:newcol = l:col + len(l:text)
    call cursor(l:linenr, l:newcol)
  endif
  return ''
endfunction

" Creates a new item below the current line with the same indent
function! todolist#create_new_item_below()
  execute "normal! o" . g:todolist#undone_item . " "
  startinsert!
endfunction

" Creates a new item above the current line with the same indent
function! todolist#create_new_item_above()
  execute "normal! O" . g:todolist#undone_item . " "
  startinsert!
endfunction

" Moves the cursor to the next item
function! todolist#go_to_next_item()
  normal! $
  silent! exec '/^\s*\(' . g:todolist#undone_item_escaped . '\|' . g:todolist#done_item_escaped . '\)'
  silent! exec 'noh'
  normal! 6l
endfunction

" Moves the cursor to the previous item
function! todolist#go_to_prev_item()
  normal! 0
  silent! exec '?^\s*\(' . g:todolist#undone_item_escaped . '\|' . g:todolist#done_item_escaped . '\)'
  silent! exec 'noh'
  normal! 6l
endfunction

" Toggles todo list item
function! todolist#toggle_item()
  let l:line = getline('.')
  let l:lineno = line('.')

  if todolist#item_is_not_done(l:line) == 1
    call todolist#set_item_done(l:lineno)
  elseif todolist#item_is_done(l:line) == 1
    call todolist#set_item_not_done(l:lineno)
  endif
endfunction
