" Improve diff usablility
" 
" See autoload for implementation
if exists('g:loaded_diffusable')
    finish
elseif !has("diff")
    if &verbose
        echoerr 'diffusable requires diff support'
    endif
    finish
elseif !exists('*win_execute')
    if &verbose
        echoerr 'diffusable requires vim with win_execute()'
    endif
    finish
endif
let g:loaded_diffusable = 1

if exists(':Scratch') != 2
    if &verbose
        echoerr 'diffusable is defining its own :Scratch command'
    endif
    command! -bar Scratch vsplit | setlocal buftype=nofile bufhidden=hide
endif

" Mappings {{{1

" Find conflict markers
" Svn and Perforce use =. Svn uses |.
nnoremap <silent> <Plug>(diffusable-next-conflict) /\v^[<>=\|]{4,7}($\|\s\|\r)<CR>
nnoremap <silent> <Plug>(diffusable-prev-conflict) ?\v^[<>=\|]{4,7}($\|\s\|\r)<CR>
" Quick diff update
nnoremap <silent> <Plug>(diffusable-update) :call diffusable#updatediff()<CR>
" undo a change in the previous window - used frequently for diff
nnoremap <silent> <Plug>(diffusable-undo-other-win) :wincmd p <bar> undo <bar> wincmd p <bar> diffupdate<CR>

if !exists("g:diffusable_no_mappings") || !g:diffusable_no_mappings
    nmap <unique> ]C <Plug>(diffusable-next-conflict)
    nmap <unique> [C <Plug>(diffusable-prev-conflict)

    " Visual mode do and dp
    xnoremap <unique> <Leader>do :diffget<CR>
    xnoremap <unique> <Leader>dp :diffput<CR>

    nmap <unique> du <Plug>(diffusable-update)

    nmap <unique> <C-w>u <Plug>(diffusable-undo-other-win)
endif


" DiffDeletes {{{1
" Diffs the last two deleted ranges.
" Opens a tab to display a diff between the inputs. Quit the diff with q
" (closes the tab).
command! -bar -nargs=0 DiffDeletes call DiffText(@1, @2)

" Diff two strings. Use @r to pass in register r.
function! DiffText(left, right)
    call diffusable#diff_text(a:left, a:right)
endfunction


" Primary File Diff Commands {{{1
command! -bar DiffBoth call diffusable#diff_both()
" TODO: Make this use diffusable#diffthis or remove
command! -bar -nargs=1 -complete=file VDiffSp vert diffsplit <q-args>
command! -bar DiffSaved call diffusable#diff_saved()
command! -bar DiffOff call diffusable#partnered_diffoff(win_getid())

" vi: et sw=4 ts=4
