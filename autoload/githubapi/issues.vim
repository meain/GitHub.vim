""
" List issues
" List all issues assigned to the authenticated user across all visible
" repositories including owned repositories, member repositories, and
" organization repositories:
"
" Github API : GET /issues
" @public
function! githubapi#issues#List_All(user,password) abort
    let issues = []
    for i in range(1,githubapi#util#GetLastPage('issues -u ' . a:user . ':' . a:password))
        call extend(issues,githubapi#util#Get('issues?page=' . i,' -u ' . a:user . ':' . a:password))
    endfor
    return issues
endfunction

""
" List all issues across owned and member repositories assigned to the
" authenticated user:
"
" Github API : GET /user/issues
" @public
function! githubapi#issues#List_All_for_User(user,password) abort
    let issues = []
    for i in range(1,githubapi#util#GetLastPage('user/issues -u ' . a:user . ':' . a:password))
        call extend(issues,githubapi#util#Get('user/issues?page=' . i,' -u ' . a:user . ':' . a:password))
    endfor
    return issues
endfunction

""
" List all issues for a given organization assigned to the authenticated user:
"
" Github API : GET /orgs/:org/issues
" @public
function! githubapi#issues#List_All_for_User_In_Org(org,user,password) abort
    let issues = []
    for i in range(1,githubapi#util#GetLastPage('orgs/' . a:org . '/issues -u ' . a:user . ':' . a:password))
        call extend(issues,githubapi#util#Get('orgs/' . a:org . '/issues?page=' . i,' -u ' . a:user . ':' . a:password))
    endfor
    return issues
endfunction

""
" List issues for a repository
" GET /repos/:owner/:repo/issues
" NOTE: this only list opened issues and pull request
function! githubapi#issues#List_All_for_Repo(owner,repo) abort
    let issues = []
    for i in range(1,githubapi#util#GetLastPage('repos/' . a:owner . '/' . a:repo . '/issues'))
        call extend(issues,githubapi#util#Get('repos/' . a:owner . '/' . a:repo . '/issues?page=' . i, ''))
    endfor
    return issues
endfunction

""
" Get a single issue
" @public
" GET /repos/:owner/:repo/issues/:number
function! githubapi#issues#Get_issue(owner,repo,num) abort
    return githubapi#util#Get('repos/' . a:owner . '/' . a:repo . '/issues/' . a:num, '')
endfunction

""
" @public
" Create an issue
"
" Github API : POST /repos/:owner/:repo/issues
"
" Input:
" {
"
"  "title": "Found a bug",
"
"  "body": "I'm having a problem with this.",
"
"  "assignee": "octocat",
"
"  "milestone": 1,
"
"  "labels": [
"
"    "bug"
"
"  ]
"
" }
function! githubapi#issues#Create(owner,repo,user,password,json) abort
    return githubapi#util#Get('repos/' . a:owner . '/' . a:repo . '/issues',
                \ ' -X POST -d ' . shellescape(a:json)
                \ . ' -u ' . a:user . ':' . a:password)
endfunction

""
" Edit an issue
" PATCH /repos/:owner/:repo/issues/:number
function! githubapi#issues#Edit(owner,repo,num,user,password,json) abort
    return githubapi#util#Get('repos/' . a:owner . '/' . a:repo . '/issues/' . a:num,
                \ ' -X PATCH -d ' . shellescape(a:json)
                \ . ' -u ' . a:user . ':' . a:password)
endfunction

""
" @public
" Lock an issue
"
" Github APi : PUT /repos/:owner/:repo/issues/:number/lock
function! githubapi#issues#Lock(owner,repo,num,user,password) abort
    return githubapi#util#Get('repos/' . a:owner . '/' . a:repo . '/issues/' . a:num . '/lock',
                \ ' -X PUT  -u ' . a:user . ':' . a:password
                \ . ' -H "Accept: application/vnd.github.the-key-preview"')
endfunction

""
" @public
" Unlock an issue
"
" Github API : DELETE /repos/:owner/:repo/issues/:number/lock
function! githubapi#issues#Unlock(owner,repo,num,user,password) abort
    return githubapi#util#Get('repos/' . a:owner . '/' . a:repo . '/issues/' . a:num . '/lock',
                \ ' -X DELETE  -u ' . a:user . ':' . a:password
                \ . ' -H "Accept: application/vnd.github.the-key-preview"')
endfunction

""
" @public
" Lists all the available assignees to which issues may be assigned.
"
" Github API : GET /repos/:owner/:repo/assignees
function! githubapi#issues#List_assignees(owner,repo) abort
    return githubapi#util#Get('repos/' . a:owner . '/' . a:repo . '/assignees', '')
endfunction

""
" @public
" Check assignee
"
" Github API : GET /repos/:owner/:repo/assignees/:assignee
function! githubapi#issues#Check_assignee(owner,repo,assignee) abort
    return githubapi#util#GetStatus('repos/' . a:owner . '/'
                \ . a:repo . '/assignees/' . a:assignee) ==# 204
endfunction

""
" @public
" Add assignees to an Issue
"
" Github API : POST /repos/:owner/:repo/issues/:number/assignees
"
" NOTE: need `Accep:application/vnd.github.cerberus-preview+json`
"
" Input:
" {
"  "assignees": [
"    "hubot",
"    "other_assignee"
"  ]
"}
function! githubapi#issues#Addassignee(owner,repo,num,assignees,user,password) abort
    return githubapi#util#Get('repos/' . a:owner . '/' . a:repo . '/issues/' . a:num . '/assignees',
                \ ' -X POST -d ' . shellescape(a:assignees) . ' -u ' . a:user . ':' . a:password
                \ . ' -H "Accept: application/vnd.github.cerberus-preview+json"')
endfunction

""
" @public
" Remove assignees from an Issue
"
" DELETE /repos/:owner/:repo/issues/:number/assignees
"
" Input:
" {
"  "assignees": [
"    "hubot",
"    "other_assignee"
"  ]
"}
"
" NOTE: need `Accep:application/vnd.github.cerberus-preview+json`
function! githubapi#issues#Removeassignee(owner,repo,num,assignees,user,password) abort
    return githubapi#util#Get('repos/' . a:owner . '/' . a:repo . '/issues/' . a:num . '/assignees',
                \ ' -X DELETE -d ' . shellescape(a:assignees) . ' -u ' . a:user . ':' . a:password
                \ . ' -H "Accept: application/vnd.github.cerberus-preview+json"')
endfunction
