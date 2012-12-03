" Improve diff usablility
"
" Inspiration:
"   DiffDeletes - http://stackoverflow.com/q/3619146/vimdiff-two-subroutines-in-same-file/#3621806
"   diffthis and diffoff - https://github.com/tpope/vim-fugitive

if exists('g:autoloaded_diffbuff')
    finish
endif
let g:autoloaded_diffbuff = 1


" Diff bits of text {{{1

" Diff two strings. Use @r to pass in register r.
function diffbuff#diff_text(left, right)
    let ft = &ft
    tabnew
    call s:CreateBuffer(a:left, ft)
    vnew
    call s:CreateBuffer(a:right, ft)
endfunction

" Setup the buffer and add the text
function s:CreateBuffer(text, ft)
    " Don't use a file, since we're for quick comparisons
    setlocal buftype=nofile
    " Use the source file's filetype for syntax highlighting
    let &l:ft = a:ft
    " Paste the data and only the data
    call setline(1, split(a:text, "\n"))
    call diffbuff#diffthis()
    " Quick quit
    nmap <buffer> q :tabclose<CR>
endfunction


" Vim diff command wrappers {{{1

" Store the diff-clobbered settings in a restore command.
function diffbuff#diffthis()
    if &diff
        return
    endif

    let w:diffbuff_restore = 'diffoff | setlocal '
    if has('cursorbind')
        let w:diffbuff_restore .= (&l:cursorbind ? ' ' : ' no') . 'cursorbind'
    endif
    let w:diffbuff_restore .= ' scrollopt=' . &l:scrollopt
    let w:diffbuff_restore .= &l:wrap ? ' wrap' : ' nowrap'
    let w:diffbuff_restore .= ' foldmethod=' . &l:foldmethod
    let w:diffbuff_restore .= ' foldcolumn=' . &l:foldcolumn
    diffthis
endfunction

" Remove diff and restore diff-clobbered settings.
function diffbuff#diffoff()
    autocmd! DiffBuff BufWinLeave <buffer>
    if exists('w:diffbuff_restore')
        execute w:diffbuff_restore
        unlet w:diffbuff_restore
    else
        diffoff
    endif
endfunction

" Diff launchers {{{1

" Diff against the file on disk. Useful for recovery. See also :help DiffOrig
function diffbuff#diff_saved() "{{{2
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

" Diff the current and last window.
function diffbuff#diff_both() "{{{2
    call diffbuff#diff_with_partner(winnr('#'))
    if winnr('#') == winnr()
        " If we are our previous window, try jumping to the next window
        " instead. This case occurs if you open a file, split, open a second
        " file. We never changed windows, so we have no previous.
        wincmd w
    else
        " Next window please.
        wincmd p
    endif
    call diffbuff#diff_with_partner(winnr('#'))
endfunction


" Partnered diff windows {{{1

" Diff this window and store the partner's window so diffoff can clean both
" up.
function diffbuff#diff_with_partner(partner_winnr)
    let w:diffbuff_partner_winnr = a:partner_winnr
    augroup DiffBuff
        " When the buffer is closed, remove diff from the partner.
        au BufWinLeave <buffer> call diffbuff#partnered_diffoff()
    augroup END
    call diffbuff#diffthis()
endfunction

" Clean up diff for this window and its partner.
function! diffbuff#partnered_diffoff()
    call diffbuff#diffoff()

    if !exists('w:diffbuff_partner_winnr') || w:diffbuff_partner_winnr == 0
        " We have no partner.
        return
    endif

    let winnr = w:diffbuff_partner_winnr
    unlet w:diffbuff_partner_winnr

    exec winnr .'wincmd w'
    " TODO: If our partner doesn't know we exist, should we still call
    " diffoff? Probably doesn't matter unless they're linked to someone else.
    " TODO: Should we check that our partner's partner is us?
    unlet! w:diffbuff_partner_winnr
    call diffbuff#diffoff()
    wincmd p
endfunction

" vi: et sw=4 ts=4 fdm=marker fmr={{{,}}}
