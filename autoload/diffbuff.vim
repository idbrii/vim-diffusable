" Diff arbitrary text
" Opens a tab to display a diff between the inputs. Quit the diff with q
" (closes the tab).

" Inspiration: http://stackoverflow.com/q/3619146/vimdiff-two-subroutines-in-same-file/#3621806

if exists('g:autoloaded_diffbuff')
    finish
endif
let g:autoloaded_diffbuff = 1

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

" Wrap vim's diff functions to restore state {{{1
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

function diffbuff#diffoff()
    autocmd! DiffBuff BufWinLeave <buffer>
    if exists('w:diffbuff_restore')
        execute w:diffbuff_restore
        unlet w:diffbuff_restore
    else
        diffoff
    endif
endfunction

" Partnered diff windows {{{1
function diffbuff#diff_with_partner(partner_winnr)
    let w:diffbuff_partner_winnr = a:partner_winnr
    augroup DiffBuff
        " When the buffer is closed, remove diff from the partner.
        au BufWinLeave <buffer> call diffbuff#partnered_diffoff()
    augroup END
    call diffbuff#diffthis()
endfunction

function! diffbuff#partnered_diffoff()
    call diffbuff#diffoff()

    if !exists('w:diffbuff_partner_winnr') || w:diffbuff_partner_winnr == 0
        return
    endif

    let winnr = w:diffbuff_partner_winnr
    unlet w:diffbuff_partner_winnr

    exec winnr .'wincmd w'
    unlet w:diffbuff_partner_winnr
    call diffbuff#diffoff()
    wincmd p
endfunction

