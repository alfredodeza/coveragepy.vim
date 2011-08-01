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
let g:coveragepy_last_session = ""
let g:coveragepy_marks        = []
let g:coveragepy_session_map    = {}


function! s:CoveragePySyntax() abort
  let b:current_syntax = 'CoveragePy'
  syn match CoveragePyTitleDecoration      "\v\-{2,}"
  syn match CoveragePyHeaders              '\v(^Name\s+|\s*Stmts\s*|\s*Miss\s+|Cover|Missing$)'
  syn match CoveragePyDelimiter            "\v^(\-\-)\s+"
  syn match CoveragePyPercent              "\v(\d+\%\s+)"
  syn match CoveragePyLineNumbers          "\v(\s*\d+,|\d+-\d+,|\d+-\d+$|\d+$)"

  hi def link CoveragePyFiles              Number
  hi def link CoveragePyHeaders            Comment
  hi def link CoveragePyTitleDecoration    Keyword
  hi def link CoveragePyDelimiter          Comment
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


function! s:ClearSigns()
    exe ":sign unplace *"
endfunction


function! s:HighlightMissing()
    sign define CoveragePy text=! linehl=Miss texthl=Error
    if (g:coveragepy_session_map == {})
        call s:Echo("No previous coverage report available")
        return
    endif
    call s:ClearSigns()
    let current_buffer = split(expand("%:r"), ".py")[0]
    for path in keys(g:coveragepy_session_map)
        if path =~ current_buffer
            for position in g:coveragepy_session_map[path]
                execute(":sign place ". position ." line=". position ." name=CoveragePy file=".expand("%:p"))
            endfor
        endif
    endfor
endfunction


function! s:Strip(input_string)
    return split(a:input_string, " ")[0]
endfunction


function! s:Roulette(direction)                                                                                                                                                                                                                                                   
    let orig_line = line('.')
    let last_line = line('$') - 3
    
    " if for some reason there is not enough
    " coverage output return
    if last_line < 3
        return
    endif

    " Move to the line we need
    let move_to = orig_line + a:direction

    if move_to > last_line
        let move_to = 3
        exe move_to
    elseif (move_to < 3) && (a:direction == -1)
        let move_to = last_line
        exe move_to
    elseif (move_to < 3) && (a:direction == 1)
        let move_to = 3
        exe move_to
    else
        exe move_to
    endif

    if move_to == 1
        let _num = move_to
    else
        let _num = move_to - 1
    endif
endfunction


function! s:CoveragePyReport()
    " Run a report, ignore errors and show missing lines,
    " which is what we are interested after all :)
    call s:ClearSigns()
    let g:coveragepy_last_session = ""
    let cmd = "coverage report -m -i" 
    let out = system(cmd)
    let g:coveragepy_last_session = out
    call s:ReportParse()
endfunction


function! s:ReportParse()
    " After coverage runs, parse the content so we can get
    " line numbers mapped to files
    let path_to_lines = {}
    for line in split(g:coveragepy_last_session, '\n')
        if (line =~ '\v(\s*\d+,|\d+-\d+,|\d+-\d+$|\d+$)') && line !~ '\v(100\%)'
            let path   = split(line, ' ')[0]
            let match_split  = split(line, '%')
            let line_nos     = match_split[-1]
            let all_line_nos = s:LineNumberParse(line_nos)
            let path_to_lines[path] = all_line_nos
        endif
    endfor
    let g:coveragepy_session_map = path_to_lines
endfunction


function! s:LineNumberParse(numbers)
    " Line numbers will come with a possible comma in them
    " and lots of extra space. Let's remove them and strip them
    let parsed_list = []
    let splitted = split(a:numbers, ',')
    for line_no in splitted
        if line_no =~ '-'
            let split_nos = split(line_no, '-')
            let first = s:Strip(split_nos[0])
            let second = s:Strip(split_nos[1])
            for range_no in range(first, second)
                call add(parsed_list, range_no)
            endfor
        else
            call add(parsed_list, s:Strip(line_no))
        endif
    endfor
    return parsed_list
endfunction


function! s:ClearAll()
    let bufferL = ['LastSession.coveragepy', 'OpenBuffer.coveragepy']
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
        call s:Echo("There is currently no saved coverage.py session to display")
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
    nnoremap <silent><script> <buffer> <C-n>   :call <sid>Roulette(1)<CR>
    nnoremap <silent><script> <buffer> <down>  :call <sid>Roulette(1)<CR>
    nnoremap <silent><script> <buffer> j       :call <sid>Roulette(1)<CR>
    nnoremap <silent><script> <buffer> <C-p>   :call <sid>Roulette(-1)<CR>
    nnoremap <silent><script> <buffer> <up>    :call <sid>Roulette(-1)<CR>
    nnoremap <silent><script> <buffer> k       :call <sid>Roulette(-1)<CR>
    nnoremap <silent> <buffer> <Enter>         :call <sid>OpenBuffer()<CR>
    call s:CoveragePySyntax()
    exe 'wincmd p'
endfunction

function! s:OpenBuffer()
    let path = split(getline('.'), ' ')[0] . '.py'
    execute 'wincmd p'
    silent! execute ":e " . path
    call s:HighlightMissing()
    execute 'wincmd p'
    call s:CoveragePySyntax()
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
    elseif (a:action == "show")
        call s:HighlightMissing()
    elseif (a:action == "noshow")
        call s:ClearSigns()
    elseif (a:action == "session")
        let winnr = bufwinnr('LastSession.coveragepy')
        if (winnr != -1)
                silent! execute 'wincmd b'
                silent! execute 'q'
            return
        else
            call s:LastSession()
        endif
    elseif (a:action == "report")
        call s:CoveragePyReport()
        call s:LastSession()
        call s:HighlightMissing()
    elseif (a:action == "version")
        call s:Version()
    endif
endfunction


command! -nargs=+ -complete=custom,s:Completion CoveragePy call s:Proxy(<f-args>)

