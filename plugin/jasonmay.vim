set encoding=utf8
syntax on
set ruler
set rulerformat=%40(%=%t%h%m%r%w%<\ (%n)\ %4.7l,%-7.(%c%V%)\ %P%)
set showmode
set showcmd
set shortmess=aotTWI
set laststatus=0
set display+=lastline,uhex
set scrolloff=3
set lazyredraw
set hlsearch
set showmatch
set matchtime=1
set report=0
set nomore
set noswapfile
set autoread 
set ttyfast
set completeopt=menuone
set incsearch
set tildeop
set backspace=indent,eol,start
"set wildmenu
set wildignore+=.log,.out,.o
set viminfo=!,'1000,f1,/1000,:1000,<1000,@1000,h,n~/.viminfo
set isfname+=:
set wildmode=longest,list,full
set hidden
set vb t_vb=
set ttimeoutlen=1

set tabstop=4
set shiftwidth=4
set softtabstop=4

set expandtab
set shiftround
set autoindent
set smartindent

set foldenable
set foldmethod=marker
set bg=light

set backupskip=/tmp/*,/private/tmp/*"

set term=linux

let perl_extended_vars=1
let perl_include_pod=1
let perl_string_as_statement=1
let perl_sync_dist=1000

filetype off
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()
filetype plugin indent on

match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'

highlight Search NONE ctermfg=lightred
highlight Folded      ctermbg=black ctermfg=blue 

autocmd BufNewFile,BufRead *.reg,*.run,repl.rc,*.repl.rc,*.psgi,*.t set ft=perl
autocmd BufNewFile,BufRead *.asl       set ft=ruby
autocmd BufNewFile,BufRead psql.edit.* set ft=sql
autocmd BufNewFile,BufRead *.tt,*.tt2  set ft=tt2html
autocmd BufNewFile,BufRead *.json      set ft=json
autocmd BufNewFile,BufRead *.p6,*.pm6  set ft=perl6
autocmd BufNewFile,BufRead *.scpt      set ft=applescript
autocmd BufNewFile,BufRead Xdefaults   set ft=Xdefaults
autocmd BufNewFile,BufRead share/html/* set ft=mason
autocmd BufNewFile,BufRead etc/upgrade/*/content set ft=perl
autocmd BufNewFile,BufRead *.md      set ft=markdown

autocmd BufNewFile,BufRead initialdata set ft=perl

autocmd FileType           ruby set tabstop=2
autocmd FileType           ruby set shiftwidth=2
autocmd FileType           ruby set softtabstop=2

autocmd FileType           perl setlocal makeprg=$VIMRUNTIME/tools/efm_perl.pl\ -c\ %\ $*
autocmd FileType           perl setlocal errorformat=%f:%l:%m

autocmd FileType           ruby set tabstop=2
autocmd FileType           ruby set shiftwidth=2
autocmd FileType           ruby set softtabstop=2

" Automatic commands
autocmd InsertEnter * syn clear EOLWS | syn match EOLWS excludenl /\s\+\%#\@!$/
autocmd InsertLeave * syn clear EOLWS | syn match EOLWS excludenl /\s\+$/
hi EOLWS ctermbg=red


autocmd FileType help nnoremap <buffer> <CR> <C-]>
autocmd FileType help nnoremap <buffer> <BS> <C-T>

"autocmd BufWritePost *.vim source ~/.vimrc
autocmd BufWritePost * source ~/.vimrc

autocmd FileType           perl highlight Operator ctermbg=Black ctermfg=DarkGray

autocmd BufReadPost *
\  if line("'\"") > 0 && line("'\"") <= line("$") |
\    exe "normal g`\"" |
\  endif

" Mappings

inoremap <silent> <C-a> <ESC>u:set paste<CR>.:set nopaste<CR>gi

nmap     Y          y$

nmap     \/         :nohl<CR>

nmap     <Right>    :bn<CR>
nmap     <Left>     :bp<CR>

imap     <Right>    <C-o>:bn<CR>
imap     <Left>     <C-o>:bp<CR>

map      <F5>       :make<CR>

nmap     H          ^
vmap     H          ^
nmap     L          $
vmap     L          $

nmap     M          :nohl<CR>:syn on<CR>:syntax sync fromstart<CR>

nmap     <Left>     :bn<CR>
nmap     <Right>    :bp<CR>

nmap     <CR>       o<Esc>
nmap     <F1>       <Esc>
inoremap <F1>       <Esc>
imap     <C-J>      <Esc>

nnoremap -          <Space>

map      <Leader>gc :!git add -p % && git commit<CR>

map      <Leader>p :set paste<CR>:r!pbpaste<CR>:set nopaste<CR>

nmap t :FufCoverageFile<CR>
nmap b :FufBuffer<CR>
nmap f :FufLine!<CR>

iabbrev to_jason   to_json
iabbrev from_jason from_json

iabbrev encode_jason   encode_json
iabbrev decode_jason   decode_json

iabbrev reponse    response
iabbrev shfit      shift
iabbrev sfhit      shift

"""" FUNCTIONS

function! s:align_assignments()
    " Patterns needed to locate assignment operators...
    let ASSIGN_OP   = '[-+*/%|&]\?=\@<!=[=~]\@!'
    let ASSIGN_LINE = '^\(.\{-}\)\s*\(' . ASSIGN_OP . '\)\(.*\)$'

    " Locate block of code to be considered (same indentation, no blanks)
    let indent_pat = '^' . matchstr(getline('.'), '^\s*') . '\S'
    let firstline  = search('^\%('. indent_pat . '\)\@!','bnW') + 1
    let lastline   = search('^\%('. indent_pat . '\)\@!', 'nW') - 1
    if lastline < 0
        let lastline = line('$')
    endif

    " Decompose lines at assignment operators...
    let lines = []
    for linetext in getline(firstline, lastline)
        let fields = matchlist(linetext, ASSIGN_LINE)
        call add(lines, fields[1:3])
    endfor

    " Determine maximal lengths of lvalue and operator...
    let op_lines = filter(copy(lines),'!empty(v:val)')
    let max_lval = max( map(copy(op_lines), 'strlen(v:val[0])') ) + 1
    let max_op   = max( map(copy(op_lines), 'strlen(v:val[1])'  ) )

    " Recompose lines with operators at the maximum length...
    let linenum = firstline
    for line in lines
        if !empty(line)
            let newline
            \    = printf("%-*s%*s%s", max_lval, line[0], max_op, line[1], line[2])
            call setline(linenum, newline)
        endif
        let linenum += 1
    endfor
endfunction
"nmap <silent> <Leader>= :call <SID>align_assignments()<CR>
nmap S :call <SID>align_assignments()<CR>
