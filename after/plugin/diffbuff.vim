" Diff arbitrary text
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
" Diffs the last two deleted ranges
command -nargs=0 DiffDeletes call DiffText(@1, @2)

" Diff two strings. Use @r to pass in register r.
function DiffText(left, right)
    call diffbuff#diff_text(a:left, a:right)
endfunction


" Primary File Diff Commands {{{1
function <SID>DiffBoth() "{{{2
    call diffbuff#diff_with_partner(winnr('#'))
    wincmd p
    call diffbuff#diff_with_partner(winnr('#'))
endfunction
command! DiffBoth call <SID>DiffBoth()
" TODO: Make this use diffbuff#diffthis or remove
command! -nargs=1 -complete=file VDiffSp vert diffsplit <q-args>

" Diff against the file on disk. Useful for recovery. See also :help DiffOrig
function <SID>DiffSaved() "{{{2
    let old_always = g:itchy_always_split
    let old_suffix = g:itchy_buffer_suffix
    let g:itchy_always_split = 2
    let g:itchy_buffer_suffix = '-Original'
    silent Scratch .
    let g:itchy_always_split = old_always
    let g:itchy_buffer_suffix = old_suffix
    silent %d
    silent r #
    silent 0d_
    DiffBoth
endfunction
command! DiffSaved call <SID>DiffSaved()

command! DiffOff call diffbuff#partnered_diffoff()

" vi: et sw=4 ts=4 fdm=marker fmr={{{,}}}
