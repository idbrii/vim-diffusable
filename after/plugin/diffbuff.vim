" Improve diff usablility
" 
" See autoload for implementation

if !has("diff")
    echoerr 'DiffBuff requires diff support'
    finish
elseif !exists('itchy_loaded') || exists(':Scratch') != 2
    echoerr 'DiffBuff requires itchy'
    finish
elseif exists('g:loaded_diffbuff')
    finish
endif
let g:loaded_diffbuff = 1


" DiffDeletes {{{1
" Diffs the last two deleted ranges.
" Opens a tab to display a diff between the inputs. Quit the diff with q
" (closes the tab).
command -nargs=0 DiffDeletes call DiffText(@1, @2)

" Diff two strings. Use @r to pass in register r.
function DiffText(left, right)
    call diffbuff#diff_text(a:left, a:right)
endfunction


" Primary File Diff Commands {{{1
command! DiffBoth call diffbuff#diff_both()
" TODO: Make this use diffbuff#diffthis or remove
command! -nargs=1 -complete=file VDiffSp vert diffsplit <q-args>
command! DiffSaved call diffbuff#diff_saved()
command! DiffOff call diffbuff#partnered_diffoff()

" vi: et sw=4 ts=4
