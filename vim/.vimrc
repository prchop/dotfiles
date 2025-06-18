" Disable compatibility with vi which can cause unexpected issues.
set nocompatible

" Enable type file detection. Vim will be able to try to detect the type of file in use.
filetype on

" Enable plugins and load plugin for the detected file type.
filetype plugin on

" Load an indent file for the detected file type.
filetype indent on

" Add numbers to each line on the left-hand side.
set number

" Auto write files when changing
set autowrite

" Highlight cursorline horizontally
set cursorline

" decrease delay when press a key
set timeoutlen=300

" Indentation
set autoindent
set smartindent

set expandtab
set tabstop=2
set softtabstop=2
set smarttab

set shiftwidth=2

if v:version >= 800
  " stop vim from silently messing with files that it shouldn't
  set nofixendofline
  " better ascii friendly listchars
  set listchars=space:*,trail:*,nbsp:*,extends:>,precedes:<,tab:\|>
  " disable automatic folding
  set foldmethod=manual
  set nofoldenable
  " set foldenable
  " set foldmethod=syntax
  " set foldlevelstart=99  " Open all folds by default
endif

" mark trailing spaces as errors (break Makefiles, etc.)
match Visual '\s\+$'

" highlight search hits
set hlsearch
set incsearch
set linebreak
set noignorecase

" disable spellcapcheck
set spc=

" avoid most of the 'Hit Enter ...' messages
set shortmess=aoOtTI

" prevents truncated yanks, deletes, etc.
set viminfo='20,<1000,s1000

" wrap when search
set wrapscan

" Set wrap line
set nowrap

" more risky, but cleaner
set nobackup
set noswapfile
set nowritebackup

set icon

"" not a fan of bracket matching or folding
"if has("eval") " vim-tiny detection
"  let g:loaded_matchparen=1
"endif
"set noshowmatch

" enable wild menu
set wildmenu

" Show command and insert mode.
set showmode

" max text width
set textwidth=72

" left column
set foldcolumn=0

" Disable bell.
set noerrorbells
set visualbell
set vb t_vb=

" Set leader key.
let g:mapleader=","

" copy paste with system clipboard
set clipboard=unnamedplus

" backgroud color
set background=dark

function! ModeName()
    let l:mode_dict = {
        \ 'n':  'NORMAL',
        \ 'i':  'INSERT',
        \ 'v':  'VISUAL',
        \ 'V':  'V-LINE',
        \ "\<C-V>": 'V-BLOCK',
        \ 'R':  'REPLACE',
        \ 'c':  'COMMAND'
    \ }

  return get(l:mode_dict, mode(), mode())
endfunction

" multi-line statusline configuration
set ruler
set laststatus=2  " 0 to not show
set statusline=   " clear default statusline

" first line: mode and basic info
set statusline+=\ [%{ModeName()}]
"set statusline+=\ %t
set statusline+=\ %m%w%r
set statusline+=\ %P
set statusline+=\ (%l:%c)
set statusline+=\ %{get(b:,'gitsigns_head','')}
"set statusline+=\ %b
"set statusline+=\ 0x%B
"set statusline+=\ buf:%n

" second line: file details
set statusline+=\ %=
set statusline+=\ %.30F
set statusline+=\ 
set statusline+=%{strlen(&fenc)?&fenc:&enc}
set statusline+=\ 
set statusline+=[%{strlen(&ft)?&ft:'none'}]
set statusline+=\ 

"set ruf=%30(%=%#LineNr#%.50F\ [%{strlen(&ft)?&ft:'none'}]\ %l:%c\ %p%%%)
"set statusline=[%{ModeName()}]\ %t\ [%n]\ %l:%c\ %m%w\ %r%=%100(%F\ [%{strlen(&ft)?&ft:'none'}]\ %{strlen(&fenc)?&fenc:&enc}\ %p%%%)

" stop complaints about switching buffer with changes
set hidden

" command history
set history=100

" check for terminal support
if has('termguicolors')
  set termguicolors
endif

" here because plugins and stuff need it
if has("syntax")
  syntax enable
endif

" fast scrolling
set ttyfast

" limit scroll line
set scrolloff=3

" netrw list style
let g:netrw_liststyle = 3

" Keymap goes here
nnoremap <C-L> :nohl<CR><C-L>
nmap <leader>w :set nowrap!<CR>
nmap <leader>p :set paste<CR>i
nnoremap <leader>, :edit **/
nnoremap <leader>f :find **/
nnoremap <leader>b :buf *
nmap <leader>e :Ex<CR>
nmap <leader>bl :buffers<CR>
nmap <leader>K :bn<CR>
map <leader>J :bp<CR>
nmap <leader>bd :bd<CR>
map <leader><F1> :set nonumber!<CR>
nmap <F2> :call <SID>SynStack()<CR>
"set pastetoggle=<F3>
map <F4> :set list!<CR>
map <F5> :set cursorline!<CR>
map <F7> :set spell!<CR>
map <F12> :set fdm=indent<CR>

" make Y consistent with D and C (yank til end)
map Y y$

" force some files to be specific file type
au bufnewfile,bufRead .goreleaser set ft=yaml
au bufnewfile,bufRead *.props set ft=jproperties
au bufnewfile,bufRead *.ddl set ft=sql
au bufnewfile,bufRead *.sh* set ft=sh
au bufnewfile,bufRead *.{peg,pegn} set ft=config
au bufnewfile,bufRead *.gotmpl set ft=go
au bufnewfile,bufRead *.profile set filetype=sh
au bufnewfile,bufRead *.crontab set filetype=crontab
au bufnewfile,bufRead *ssh/config set filetype=sshconfig
au bufnewfile,bufRead .dockerignore set filetype=gitignore
au bufnewfile,bufRead .bashrc,.bash_profile set filetype=bash
au bufnewfile,bufRead *gitconfig set filetype=gitconfig
au bufnewfile,bufRead /tmp/psql.edit.* set syntax=sql
au bufnewfile,bufRead *.go set nospell spellcapcheck=0
au bufnewfile,bufRead commands.yaml set spell
au bufnewfile,bufRead *.{txt,md,adoc} set spell nonumber

" base default color changes (gruvbox dark friendly)
hi StatusLine ctermfg=black ctermbg=NONE
hi StatusLineNC ctermfg=black ctermbg=NONE
hi Normal ctermbg=NONE
hi Special ctermfg=cyan
hi LineNr ctermfg=black ctermbg=NONE
hi SpecialKey ctermfg=black ctermbg=NONE
hi ModeMsg ctermfg=black cterm=NONE ctermbg=NONE
hi MoreMsg ctermfg=black ctermbg=NONE
hi NonText ctermfg=black ctermbg=NONE
hi vimGlobal ctermfg=black ctermbg=NONE
hi ErrorMsg ctermbg=234 ctermfg=darkred cterm=NONE
hi Error ctermbg=234 ctermfg=darkred cterm=NONE
hi SpellBad ctermbg=234 ctermfg=darkred cterm=NONE
hi SpellRare ctermbg=234 ctermfg=darkred cterm=NONE
hi Search ctermbg=236 ctermfg=darkred
hi vimTodo ctermbg=236 ctermfg=darkred
hi Todo ctermbg=236 ctermfg=darkred
hi IncSearch ctermbg=236 cterm=NONE ctermfg=darkred
hi MatchParen ctermbg=236 ctermfg=darkred
hi SignColumn ctermbg=NONE " make gutter less annoying
hi WinBar ctermfg=black ctermbg=NONE cterm=NONE

" color overrides
au FileType * hi StatusLine ctermfg=black ctermbg=NONE
au FileType * hi StatusLineNC ctermfg=black ctermbg=NONE
au FileType * hi Normal ctermbg=NONE
au FileType * hi Special ctermfg=cyan
au FileType * hi LineNr ctermfg=black ctermbg=NONE
au FileType * hi SpecialKey ctermfg=black ctermbg=NONE
au FileType * hi ModeMsg ctermfg=black cterm=NONE ctermbg=NONE
au FileType * hi MoreMsg ctermfg=black ctermbg=NONE
au FileType * hi NonText ctermfg=black ctermbg=NONE
au FileType * hi vimGlobal ctermfg=black ctermbg=NONE
au FileType * hi Comment ctermfg=black ctermbg=NONE
au FileType * hi ErrorMsg ctermbg=234 ctermfg=darkred cterm=NONE
au FileType * hi Error ctermbg=234 ctermfg=darkred cterm=NONE
au FileType * hi SpellBad ctermbg=234 ctermfg=darkred cterm=NONE
au FileType * hi SpellRare ctermbg=234 ctermfg=darkred cterm=NONE
au FileType * hi Search ctermbg=236 ctermfg=darkred
au FileType * hi vimTodo ctermbg=236 ctermfg=darkred
au FileType * hi Todo ctermbg=236 ctermfg=darkred
au FileType * hi MatchParen ctermbg=236 ctermfg=darkred
au FileType markdown,pandoc hi Title ctermfg=yellow ctermbg=NONE
au FileType markdown,pandoc hi Operator ctermfg=yellow ctermbg=NONE
au FileType markdown,pandoc set tw=0
au FileType markdown,pandoc set wrap
au FileType yaml hi yamlBlockMappingKey ctermfg=NONE
au FileType yaml set sw=2
au FileType sh,bash set sw=2
au FileType c set sw=8
au FileType markdown,pandoc,asciidoc noremap j gj
au FileType markdown,pandoc,asciidoc noremap k gk
au FileType sh,bash set noet

" force loclist to always close when buffer does (affects vim-go, etc.)
augroup CloseLoclistWindowGroup
  autocmd!
  autocmd QuitPre * if empty(&buftype) | lclose | endif
augroup END

"autocmd BufWritePost *.{md,adoc} silent !toemoji %

"fix bork bash detection
if has("eval")  " vim-tiny detection
fun! s:DetectBash()
    if getline(1) == '#!/usr/bin/bash'
          \ || getline(1) == '#!/bin/bash'
          \ || getline(1) == '#!/usr/bin/env bash'
        set ft=bash
        set shiftwidth=2
    endif
endfun
autocmd BufNewFile,BufRead * call s:DetectBash()
endif

" displays all the syntax rules for current position, useful
" when writing vimscript syntax plugins
if has("syntax")
function! <SID>SynStack()
  if !exists("*synstack")
    return
  endif
    echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc
endif

" start at last place you were editing
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" enable omni-completion
"set omnifunc=syntaxcomplete#Complete
"set completeopt=menu,menuone,popup
"imap <tab><tab> <c-x><c-o>

" Install vim-plug if not found
if has('nvim') || v:version >= 9.0
  if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  endif
endif

" only load plugins if Plug detected
if filereadable(expand("~/.vim/autoload/plug.vim"))

  " github.com/junegunn/vim-plug
  " There can only be one plug#begin block so all this
  " has to be here instead of split into init.lua as well.

  call plug#begin('~/.local/share/vim/plugins')
    Plug 'conradirwin/vim-bracketed-paste'
    Plug 'sainnhe/gruvbox-material'
    Plug 'fatih/vim-go' " GoInstallBinaries separately
    Plug 'vim-pandoc/vim-pandoc'
    Plug 'rwxrob/vim-pandoc-syntax-simple'
    "Plug 'habamax/vim-asciidoctor'
    "Plug 'kana/vim-textobj-user'
    "Plug 'mjakl/vim-asciidoc'
    "Plug 'preservim/nerdtree'
    Plug 'dense-analysis/ale'

    if has('nvim') || v:version >= 10.0
      Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
      Plug 'neoclide/coc.nvim', {'branch': 'release'}
      "harpoon setup
      Plug 'nvim-lua/plenary.nvim',
      Plug 'ThePrimeagen/harpoon', {'branch': 'harpoon2'}
      "gitsigns
      Plug 'lewis6991/gitsigns.nvim',
      if exists('$NVIM_SCREENKEY')
        Plug 'NStefan002/screenkey.nvim'
      endif
    endif

    if has('nvim') || v:version >= 800
      Plug 'xolox/vim-misc'
      Plug 'xolox/vim-lua-ftplugin'
    else
      Plug 'dahu/vim-asciidoc'
    endif
  call plug#end()


  " lsp completion
  let g:go_def_mapping_enabled = 0
  nmap <silent> gd <Plug>(coc-definition)
  nmap <silent> gy <Plug>(coc-type-definition)
  nmap <silent> gi <Plug>(coc-implementation)
  nmap <silent> gr <Plug>(coc-references)
  inoremap <silent><expr> <CR>
        \ coc#pum#visible() && coc#pum#info()['index'] != -1
        \ ? coc#pum#insert()
        \ : "\<C-g>u\<CR>"

  "let g:vim_asciidoc_initial_foldlevel=1

  " disable ALE's LSP completion (use CoC instead)
  let g:ale_completion_enabled = 0

  set signcolumn=yes
  let g:ale_set_signs = 1
  let g:ale_sign_info = '✨'
  let g:ale_sign_error = '🔥'
  let g:ale_sign_warning = '❗️'
  let g:ale_sign_hint = '💡'

  " perl stuff needs cpan install (brew also works):
  "   Perl::Tidy
  "   Perl::Critic

  " gopls, gometalinter
  let g:ale_linters = {
        \'go': [],
        \'perl': ['perl', 'perlcritic'],
        \'python': [],
        \'typescript': [],
        \'javascript': [],
        \}
  let g:ale_linter_aliases = {'bash': 'sh'}
  let g:ale_perl_perlcritic_options = '--severity 3'

  let g:ale_fixers = {
        \'sh': ['shfmt'],
        \'bash': ['shfmt'],
        \'perl': ['perltidy'],
        \'python': ['ruff', 'ruff_format'],
        \'javascript':['prettier', 'eslint'],
        \'typescript':['prettier', 'eslint'],
        \}
  let g:ale_fix_on_save = 1
  let g:ale_perl_perltidy_options = '-b'

  let g:ale_linters_ignore = {
  \   "typescript": ['tsserver', 'eslint', 'standard', 'xo', 'dprint', 'biome', 'tslint'],
  \   "javascript": ['tsserver', 'eslint', 'standard', 'xo', 'dprint', 'biome', 'tslint'],
  \}

  " pandoc
  let g:pandoc#formatting#mode = 'h' " A'
  let g:pandoc#formatting#textwidth = 72

  " golang (vim-go)
  let g:go_fmt_fail_silently = 0
  "let g:go_fmt_options = '-s'
  let g:go_fmt_command = 'goimports'
  let g:go_fmt_autosave = 1
  let g:go_gopls_enabled = 1
  let g:go_highlight_types = 1
  let g:go_highlight_fields = 1
  let g:go_highlight_functions = 1
  let g:go_highlight_function_calls = 1
  let g:go_highlight_operators = 1
  let g:go_highlight_extra_types = 1
  let g:go_highlight_variable_declarations = 1
  let g:go_highlight_variable_assignments = 1
  let g:go_highlight_build_constraints = 1
  let g:go_highlight_diagnostic_errors = 1
  let g:go_highlight_diagnostic_warnings = 1
  let g:go_code_completion_enabled = 0
  let g:go_auto_sameids = 0
  set updatetime=100

  " common go macros
  au FileType go nmap <leader>m ilog.Print("made")<CR><ESC>
  au FileType go nmap <leader>n iif err != nil {return err}<CR><ESC>

  "let g:gruvbox_material_dim_inactive_windows = 0
  let g:gruvbox_material_foreground = 'mix'
  let g:gruvbox_material_transparent_background = 1
  if !exists('g:colors_name') || g:colors_name !=# 'gruvbox-material'
    try
      colorscheme gruvbox-material
    catch /^Vim\%((\a\+)\)\=:E185/
      colorscheme desert
    endtry
  endif

else
  autocmd vimleavepre *.go !gofmt -w % " backup if fatih fails
endif

" higlight when yanking
autocmd TextYankPost * silent! lua vim.highlight.on_yank {higroup='Visual', timeout=300}

" CoC Setup for JS/TS only
augroup CocJSTS
  autocmd!
  autocmd FileType javascript,javascriptreact,typescript,typescriptreact let b:ale_enabled = 1
  autocmd FileType javascript,javascriptreact,typescript,typescriptreact nnoremap <buffer> <silent> K :call CocActionAsync('doHover')<CR>
augroup END

" CoC Setup for python only
augroup CocPython
  autocmd!
  autocmd FileType python,py let b:ale_enabled = 1
  autocmd FileType python,py nnoremap <buffer> <silent> K :call CocActionAsync('doHover')<CR>
augroup END

" set TMUX window name to name of file
" longer version `. expand('%:p:h:t') . '/' . expand('%:t')`
if exists('$TMUX')
    autocmd BufEnter * call system('tmux rename-window ' . expand('%:p:h:t') . '/' . expand('%:t'))
endif
