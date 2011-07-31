" File:        coveragepy.vim
" Description: Displays coverage reports from Ned Batchelder's excellent
"              coverage.py tool 
"              (see: http://nedbatchelder.com/code/coverage )
" Maintainer:  Alfredo Deza <alfredodeza AT gmail.com>
" License:     MIT
"============================================================================


if exists("g:loaded_coveragepy") || &cp 
  finish
endif

" Global variables for registering next/previous error
let g:coveragepy_last_session      = ""


function! s:CoveragePySyntax() abort
  let b:current_syntax = 'CoveragePy'
  syn match CoveragePyTitleDecoration      "\v\-{2,}"
  syn match CoveragePyHeaders              '\v(^Name\s+|\s*Stmts\s*|\s*Miss\s+|Cover|Missing$)'
  syn match CoveragePyDelimiter            "\v^(\-\-)\s+"
  syn match CoveragePyPercent              "\v(\d+\%\s+)"
  syn match CoveragePyLineNumbers          "\v(\s*\d+,|\d+-\d+,|\d+-\d+$|\d+$)"

  hi def link CoveragePyFiles              Number
  hi def link CoveragePyHeaders            Keyword
  hi def link CoveragePyTitleDecoration    Keyword
  hi def link CoveragePyDelimiter          Keyword
  hi def link CoveragePyPercent            Boolean
  hi def link CoveragePyLineNumbers        Error
endfunction


function! s:Echo(msg, ...)
    redraw!
    let x=&ruler | let y=&showcmd
    set noruler noshowcmd
    if (a:0 == 1)
        echo a:msg
    else
        echohl WarningMsg | echo a:msg | echohl None
    endif

    let &ruler=x | let &showcmd=y
endfun


function! s:Strip(input_string)
    return split(a:input_string, "'")[0]
endfunction


function! s:CoveragePyReport()
    " Run a report, ignore errors and show missing lines,
    " which is what we are interested after all :)
    let g:coveragepy_last_session = ""
    let cmd = "coverage report -m -i" 
    let out = system(cmd)
    let g:coveragepy_last_session = out
endfunction


function! s:ClearAll()
    let bufferL = ['LastSession.coveragepy']
    for b in bufferL
        let _window = bufwinnr(b)
        if (_window != -1)
            silent! execute _window . 'wincmd w'
            silent! execute 'q'
        endif
    endfor
endfunction


function! s:LastSession()
    call s:ClearAll()
    if (len(g:coveragepy_last_session) == 0)
        call s:Echo("There is currently no saved coverage.py last session to display")
        return
    endif
	let winnr = bufwinnr('LastSession.coveragepy')
	silent! execute  winnr < 0 ? 'botright new ' . 'LastSession.coveragepy' : winnr . 'wincmd w'
	setlocal buftype=nowrite bufhidden=wipe nobuflisted noswapfile nowrap number filetype=coveragepy
    let session = split(g:coveragepy_last_session, '\n')
    call append(0, session)
	silent! execute 'resize ' . line('$')
    silent! execute 'normal gg'
    silent! execute 'nnoremap <silent> <buffer> q :q! <CR>'
    call s:CoveragePySyntax()
    exe 'wincmd p'
endfunction


function! s:EditFile(path, win_type)
    call s:ClearAll()
    let path = split(a:path, ">> ")[0]
    if a:win_type == "split"
        let split = ":botright split "
    elseif a:win_type == "vertical"
        let split = ":botright vsplit "
    endif
    silent! execute split . path
    silent! execute 'nnoremap <silent> <buffer> q :q! <CR>'
endfunction


function! s:Version()
    call s:Echo("coveragepy version 0.0.1dev", 1)
endfunction


function! s:Completion(ArgLead, CmdLine, CursorPos)
    let actions = "report\nreload\nshow\nnoshow\nsession\n"
    let extras  = "version\n"
    return actions . extras
endfunction


function! s:Proxy(action, ...)
    if (a:action == "template")
        call s:FindTemplate()
    elseif (a:action == "session")
        call s:LastSession()
    elseif (a:action == "report")
        call s:CoveragePyReport()
        call s:LastSession()
    elseif (a:action == "version")
        call s:Version()
    endif
endfunction


command! -nargs=+ -complete=custom,s:Completion CoveragePy call s:Proxy(<f-args>)

