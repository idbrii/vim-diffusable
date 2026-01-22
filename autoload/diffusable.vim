" Improve diff usablility
"
" Inspiration:
"   DiffDeletes - http://stackoverflow.com/q/3619146/vimdiff-two-subroutines-in-same-file/#3621806
"   diffthis and diffoff - https://github.com/tpope/vim-fugitive

if exists('g:autoloaded_diffusable')
    finish
endif
let g:autoloaded_diffusable = 1


" Diff bits of text {{{1

" Diff two strings. Use @r to pass in register r.
function! diffusable#diff_text(left, right)
    let ft = &ft
    tabnew
    call s:CreateBuffer(a:left, ft)
    vnew
    call s:CreateBuffer(a:right, ft)
endfunction

" Diff a string against the current file.
"
" Useful for diffing from version control:
"   call diffusable#diff_this_against_text(system('vcs cat '. expand('%')))
function! diffusable#diff_this_against_text(left)
    let ft = &ft
    vnew
    call s:CreateBuffer(a:left, ft)
    " Didn't create a tab, so don't quick close it.
    unmap <buffer> q
    wincmd p
    " Must use diff both to be partnered.
    DiffBoth
endfunction

" Setup the buffer and add the text
function! s:CreateBuffer(text, ft)
    " Don't use a file, since we're for quick comparisons
    setlocal buftype=nofile
    " Once buffer is not visible, forget about it to avoid cluttering the
    " buffer list and ensure diff is turned off.
    setlocal bufhidden=delete
    " Use the source file's filetype for syntax highlighting
    let &l:ft = a:ft
    " Paste the data and only the data
    call setline(1, split(a:text, "\n"))
    call diffusable#diffthis()
    " Quick quit
    nnoremap <buffer> gq :<C-U>tabclose<CR>
endfunction


" Vim diff command wrappers {{{1

" Quick diff update
" The error is useful so I don't wonder why nothing happened. (When I forget
" what the mapping does.)
function! diffusable#updatediff()
    if &diff
        diffupdate
    else
        echom 'E99: Current buffer is not in diff mode'
    endif
endfunction

" Store the diff-clobbered settings in a restore command.
function! diffusable#diffthis()
    if &diff
        return
    endif

    let w:diffusable_restore = 'diffoff | setlocal '
    if has('cursorbind')
        let w:diffusable_restore .= (&l:cursorbind ? ' ' : ' no') . 'cursorbind'
    endif
    let w:diffusable_restore .= ' scrollopt=' . &l:scrollopt
    let w:diffusable_restore .= &l:wrap ? ' wrap' : ' nowrap'
    let w:diffusable_restore .= ' foldmethod=' . &l:foldmethod
    let w:diffusable_restore .= ' foldcolumn=' . &l:foldcolumn
    diffthis
endfunction

" Remove diff and restore diff-clobbered settings.
function! diffusable#diffoff()
    autocmd! DiffBuff BufWinLeave <buffer>
    if exists('w:diffusable_restore')
        execute w:diffusable_restore
        unlet w:diffusable_restore
    else
        diffoff
    endif
endfunction

let s:white_opt = {
            \    'iwhite': 'Ignore changes in amount of white space.',
            \    'iwhiteall': 'Ignore all white space changes.',
            \    'iwhiteeol': 'Ignore white space changes at end of line.'
            \}
function! diffusable#cycle_ignore_whitespace(force_toggle) abort
    let matches = split(&diffopt, ',')->filter({ i, v -> v =~# 'iwhite' })
    let current = ''
    for opt in matches
        exec 'set diffopt-='.. opt
        let current = opt
    endfor

    let keys = s:white_opt->keys()->sort()
    let choice = index(keys, current) + 1
    let choice = choice % (len(keys) + 1)

    if a:force_toggle
        if empty(current)
            let choice = index(keys, 'iwhiteall')
        else
            let choice = 100
        endif
    endif
    
    if choice < len(keys)
        let choice = keys[choice]
        exec 'set diffopt+='.. choice
        echo printf("diffopt+=%s: %s", choice, s:white_opt[choice])
    else
        echo "diffopt-=iwhite*: Diffing whitespace (ignore disabled)."
    endif
endf


" Jump to next line that was modified (but not added or removed).
function! diffusable#jump_to_modified_line_next()
    if !&diff
        return
    endif
    let DIFF_CHANGE = hlID('DiffChange')
    let lnum = line('.')
    let col_num = col('.')
    while lnum <= line('$') && diff_hlID(lnum, col_num) >= DIFF_CHANGE
        let col_num += 1
        if col_num > len(getline(lnum))
            let lnum += 1
            let col_num = 1
        endif
    endwhile
    while lnum <= line('$') && diff_hlID(lnum, col_num) < DIFF_CHANGE
        let col_num += 1
        if col_num > len(getline(lnum))
            let lnum += 1
            let col_num = 1
        endif
    endwhile
    if diff_hlID(lnum, col_num) >= DIFF_CHANGE
        call cursor(lnum, col_num)
    endif
endfunction

function! diffusable#jump_to_modified_line_prev()
    let DIFF_CHANGE = hlID('DiffChange')
    let lnum = line('.')
    let col_num = col('.')
    while lnum >= 1 && diff_hlID(lnum, col_num) >= DIFF_CHANGE
        let col_num -= 1
        if col_num < 1
            let lnum -= 1
            if lnum < 1
                break
            endif
            let col_num = len(getline(lnum))
        endif
    endwhile
    while lnum >= 1 && diff_hlID(lnum, col_num) < DIFF_CHANGE
        let col_num -= 1
        if col_num < 1
            let lnum -= 1
            if lnum < 1
                break
            endif
            let col_num = len(getline(lnum))
        endif
    endwhile
    if lnum >= 1 && diff_hlID(lnum, col_num) >= DIFF_CHANGE
        call cursor(lnum, col_num)
    endif
endfunction

nnoremap <silent> <Leader>]c :call diffusable#jump_to_modified_line_next()<CR>
nnoremap <silent> <Leader>[c :call diffusable#jump_to_modified_line_prev()<CR>

" Diff launchers {{{1

" Diff against the file on disk. Useful for recovery. See also :help DiffOrig
function! diffusable#diff_saved() "{{{2
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
function! diffusable#diff_both() "{{{2
    let id1 = win_getid()
    if winnr('#') == winnr()
        " If we are our previous window, try jumping to the next window
        " instead. This case occurs when you close a window -- there's no
        " previous window. Might happen if you were going to split manually,
        " but decided to use DiffBoth.
        " Repro:
        "   split hello | close | DiffBoth
        wincmd w
    else
        " Back to previous window.
        wincmd p
    endif
    let id2 = win_getid()
    if id1 == id2
        echoerr "Failed to find another window."
        return
    endif
    
    call diffusable#diff_with_partner(id1)
    wincmd p
    call diffusable#diff_with_partner(id2)
endfunction


" Partnered diff windows {{{1

" Diff this window and store the partner's window so diffoff can clean both
" up.
function! diffusable#diff_with_partner(partner_winid)
    let w:diffusable_partner_winid = a:partner_winid
    augroup DiffBuff
        " When the buffer is closed, remove diff from the partner.
        au BufWinLeave <buffer> call diffusable#partnered_diffoff(s:get_partner_winid_for_bufnr("<abuf>"))
    augroup END
    call diffusable#diffthis()
endfunction

function! s:get_partner_winid_for_bufnr(bufnr)
    return getwinvar(bufwinid(a:bufnr), 'diffusable_partner_winid')
endf

" Clean up diff for input window and its partner.
function! diffusable#partnered_diffoff(partner_winid)
    let winid = getwinvar(a:partner_winid, 'diffusable_partner_winid', 0)
    call setwinvar(a:partner_winid, 'diffusable_partner_winid', 0)
    call win_execute(a:partner_winid, 'call diffusable#diffoff()')

    if winid == 0
        " We have no partner to cleanup.
        return
    endif

    " TODO: Should we check that our partner's partner is us?
    call setwinvar(winid, 'diffusable_partner_winid', 0)
    call win_execute(winid, 'call diffusable#diffoff()')
endfunction

" vi: et sw=4 ts=4 fdm=marker fmr={{{,}}}
