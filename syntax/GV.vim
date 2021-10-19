if exists("b:current_syntax")
  finish
endif

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
hi def link gvDate   Number
hi def link gvSha    Identifier
hi def link gvTag    Constant
hi def link gvGitHub Label
hi def link gvJira   Label
hi def link gvMeta   Conditional
hi def link gvAuthor String

syn match gvAdded     "^\W*\zsA\t.*"
syn match gvDeleted   "^\W*\zsD\t.*"
hi def link gvAdded    diffAdded
hi def link gvDeleted  diffRemoved

syn match diffAdded   "^+.*"
syn match diffRemoved "^-.*"
syn match diffLine    "^@.*"
syn match diffFile    "^diff\>.*"
syn match diffFile    "^+++ .*"
syn match diffNewFile "^--- .*"
hi def link diffFile    Type
hi def link diffNewFile diffFile
hi def link diffAdded   Identifier
hi def link diffRemoved Special
hi def link diffFile    Type
hi def link diffLine    Statement
