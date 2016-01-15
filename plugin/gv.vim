" The MIT License (MIT)
"
" Copyright (c) 2016 Junegunn Choi
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
" THE SOFTWARE.

function! s:warn(message)
  echohl WarningMsg | echom a:message | echohl None
endfunction

function! s:shrug()
  call s:warn('¯\_(ツ)_/¯')
endfunction

function! s:sha(...)
  return matchstr(get(a:000, 0, getline('.')), '^[^0-9]*[0-9-]\+\s\+\zs[a-f0-9]\+')
endfunction

function! s:browse(url)
  call netrw#BrowseX(b:git_origin.a:url, 0)
endfunction

function! s:gbrowse()
  let sha = s:sha()
  if empty(sha)
    return s:shrug()
  endif
  execute 'Gbrowse' sha
endfunction

function! s:type(visual)
  if a:visual
    let shas = filter(map(getline("'<", "'>"), 's:sha(v:val)'), '!empty(v:val)')
    if len(shas) < 2
      return [0, 0]
    endif
    return ['diff', fugitive#repo().git_command('diff', shas[-1], shas[0])]
  endif

  if exists('b:git_origin')
    let syn = synIDattr(synID(line('.'), col('.'), 0), 'name')
    if syn == 'gvGitHub'
      return ['link', '/issues/'.expand('<cword>')[1:]]
    elseif syn == 'gvTag'
      let tag = matchstr(getline('.'), '(tag: \zs[^ ,)]\+')
      return ['link', '/releases/'.tag]
    endif
  endif

  let sha = s:sha()
  if !empty(sha)
    return ['commit', 'fugitive://'.b:git_dir.'//'.sha]
  endif
  return [0, 0]
endfunction

function! s:split(tab)
  if a:tab
    tabnew
  elseif getwinvar(winnr('$'), 'gv')
    $wincmd w
    enew
  else
    vertical botright new
  endif
  let w:gv = 1
endfunction

function! s:open(visual, ...)
  let [type, target] = s:type(a:visual)

  if empty(type)
    return s:shrug()
  elseif type == 'link'
    return s:browse(target)
  endif

  call s:split(a:0)
  if type == 'commit'
    execute 'e' target
    nnoremap <silent> <buffer> gb :Gbrowse<cr>
  elseif type == 'diff'
    call s:scratch()
    call s:fill(target)
    setf diff
  endif
  nnoremap <silent> <buffer> q :close<cr>
  wincmd p
  echo
endfunction

function! s:syntax()
  syn clear
  syn match gvInfo    /^[^0-9]*\zs[0-9-]\+\s\+[a-f0-9]\+ / contains=gvDate,gvSha nextgroup=gvMessage,gvMeta
  syn match gvDate    /\S\+ / contained
  syn match gvSha     /[a-f0-9]\{6,}/ contained
  syn match gvMessage /.* \ze(.\{-})$/ contained contains=gvTag,gvGitHub,gvJira nextgroup=gvAuthor
  syn match gvAuthor  /.*$/ contained
  syn match gvMeta    /([^)]\+) / contained contains=gvTag nextgroup=gvMessage
  syn match gvTag     /(tag:[^)]\+)/ contained
  syn match gvGitHub  /\<#[0-9]\+\>/ contained
  syn match gvJira    /\<[A-Z]\+-[0-9]\+\>/ contained
  hi  link  gvDate    Number
  hi  link  gvSha     Identifier
  hi  link  gvTag     Constant
  hi  link  gvGitHub  Label
  hi  link  gvJira    Label
  hi  link  gvMeta    Conditional
  hi  link  gvAuthor  String
endfunction

function! s:maps()
  nnoremap <silent> <buffer> q    :tabclose<cr>
  nnoremap <silent> <buffer> gb   :call <sid>gbrowse()<cr>
  nnoremap <silent> <buffer> <cr> :call <sid>open(0)<cr>
  nnoremap <silent> <buffer> o    :call <sid>open(0)<cr>
  nnoremap <silent> <buffer> O    :call <sid>open(0, 1)<cr>
  xnoremap <silent> <buffer> <cr> :<c-u>call <sid>open(1)<cr>
  xnoremap <silent> <buffer> o    :<c-u>call <sid>open(1)<cr>
  xnoremap <silent> <buffer> O    :<c-u>call <sid>open(1, 1)<cr>
endfunction

function! s:setup(git_dir, git_origin)
  tabnew
  call s:scratch()

  let origin = matchstr(a:git_origin, 'github.com[/:]\zs.\{-}\ze\(.git\)\?$')
  if !empty(origin)
    let b:git_origin = 'https://github.com/'.origin
  endif
  let b:git_dir = a:git_dir
endfunction

function! s:git_dir()
  if empty(get(b:, 'git_dir', ''))
    return fugitive#extract_git_dir(expand('%:p'))
  endif
  return b:git_dir
endfunction

function! s:scratch()
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
endfunction

function! s:fill(cmd)
  setlocal modifiable
  silent execute 'read' escape('!'.a:cmd, '%')
  normal! gg"_dd
  setlocal nomodifiable
endfunction

function! s:log_opts(fugitive_repo, bang)
  let current = expand('%')
  if a:bang && !empty(current)
    call system(a:fugitive_repo.git_command('ls-files', '--error-unmatch', current))
    if !v:shell_error
      return ['--follow', current]
    endif
  endif
  return []
endfunction

function! s:list(fugitive_repo, log_opts)
  let default_opts = ['--graph', '--color=never', '--date=short', '--format=%cd %h%d %s (%an)']
  let git_args = ['log'] + default_opts + a:log_opts
  let git_log_cmd = call(a:fugitive_repo.git_command, git_args, a:fugitive_repo)
  call s:fill(git_log_cmd)
  setlocal nowrap cursorline iskeyword+=#

  if !exists(':Gbrowse')
    doautocmd User Fugitive
  endif

  call s:syntax()
  call s:maps()
  redraw
  echo 'o: open split / O: open tab / gb: Gbrowse / q: quit'
endfunction

function! s:gv(bang) abort
  if !exists('g:loaded_fugitive')
    return s:warn('fugitive not found')
  endif

  let git_dir = s:git_dir()
  if empty(git_dir)
    return s:warn('not in git repo')
  endif

  let fugitive_repo = fugitive#repo(git_dir)
  let log_opts = s:log_opts(fugitive_repo, a:bang)
  call s:setup(git_dir, fugitive_repo.config('remote.origin.url'))
  call s:list(fugitive_repo, log_opts)
endfunction

command! -bang GV call s:gv(<bang>0)
