function! s:systemlist(cmd) abort
    let cmd = ''
    if type(a:cmd) == type([]) && !has('nvim')
        let cmd = join(a:cmd, " ")
    endif
    call github#api#util#log('systemlist cmd : ' . string(cmd))
    return systemlist(cmd)
endfunction

function! github#api#util#Get(url,args) abort
    let cmd = ['curl', '-s', g:githubapi_root_url . a:url]
    if len(a:args) > 0
        call extend(cmd, a:args)
    endif
    call github#api#util#log('util#Get cmd : ' . string(cmd))
    let result = join(s:systemlist(cmd),"\n")
    return empty(result) ? result : json_decode(result)
endfunction

function! github#api#util#GetLastPage(url) abort
    let cmd = ['curl', '-si', g:githubapi_root_url . a:url]
    call github#api#util#log('util#GetLastPage cmd : ' . string(cmd))
    let result = filter(copy(systemlist(cmd)), "v:val =~# '^Link'")
    if len(result) > 0
        let line = result[0]
        if !empty(line) && !empty(matchstr(line, 'rel="last"'))
            return split(matchstr(line,'=\d\+',0,2),'=')[0]
        endif
    else
        return 1
    endif
endfunction

function! github#api#util#GetStatus(url,opt) abort
    let cmd = ['curl', '-is', g:githubapi_root_url . a:url]
    if len(a:opt) > 0
        call extend(cmd, a:opt)
    endif
    call github#api#util#log('util#GetStatus cmd : ' . string(cmd))
    let result = filter(copy(systemlist(cmd)), "v:val =~# '^Status:'")
    return matchstr(result[0],'\d\+')
endfunction

""
" @public
" Get current time in a timestamp in ISO 8601 format: YYYY-MM-DDTHH:MM:SSZ
function! github#api#util#Get_current_time() abort
   return strftime('%Y-%m-%dT%TZ')
endfunction

let s:log = []
function! github#api#util#log(log) abort
    call add(s:log, a:log)
endfunction

""
" @public
" view the log of API
function! github#api#util#GetLog() abort
    return join(s:log, "\n")
endfunction

""
" @public
"
" Clean up the log of the API
function! github#api#util#CleanLog() abort
    let s:log = []
    echon "Github-api.vim's log has beed cleaned up!"
endfunction

function! github#api#util#parserArgs(base,name,var,values,default) abort
    if empty(a:default) && index(a:values, a:var) == -1
        return a:base
    endif
    let url = a:base . (stridx(a:base, '?') ==# -1 ? '?' : '&')
    if index(a:values, a:var) == -1
        let url .= a:name . '=' . a:default
    else
        let url .= a:name . '=' . a:var
    endif
    return url
endfunction
