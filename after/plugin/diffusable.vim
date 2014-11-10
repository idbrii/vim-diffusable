" Improve diff usablility
" 
" See autoload for implementation

if !has("diff")
    echoerr 'diffusable requires diff support'
    finish
elseif !exists('itchy_loaded') || exists(':Scratch') != 2
    echoerr 'diffusable requires itchy'
    finish
elseif exists('g:loaded_diffusable')
    finish
endif
let g:loaded_diffusable = 1


" Mappings {{{1
if !exists("g:diffusable_no_mappings") || !g:diffusable_no_mappings
    " Find conflict markers
    nnoremap <silent> ]C /\v^[<>=]{4,7}($\|\s)<CR>
    nnoremap <silent> [C ?\v^[<>=]{4,7}($\|\s)<CR>

    " Visual mode do and dp
    xnoremap <unique> <Leader>do :diffget<CR>
    xnoremap <unique> <Leader>dp :diffput<CR>

    " Quick diff update
    nnoremap <silent> du :call diffusable#updatediff()<CR>

    " undo a change in the previous window - used frequently for diff
    nnoremap <C-w>u :wincmd p <bar> undo <bar> wincmd p <bar> diffupdate<CR>
endif


" DiffDeletes {{{1
" Diffs the last two deleted ranges.
" Opens a tab to display a diff between the inputs. Quit the diff with q
" (closes the tab).
command -nargs=0 DiffDeletes call DiffText(@1, @2)

" Diff two strings. Use @r to pass in register r.
function DiffText(left, right)
    call diffusable#diff_text(a:left, a:right)
endfunction


" Primary File Diff Commands {{{1
command! DiffBoth call diffusable#diff_both()
" TODO: Make this use diffusable#diffthis or remove
command! -nargs=1 -complete=file VDiffSp vert diffsplit <q-args>
command! DiffSaved call diffusable#diff_saved()
command! DiffOff call diffusable#partnered_diffoff()

" vi: et sw=4 ts=4
