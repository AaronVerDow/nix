colorscheme humanoid

let g:goyo_width = 82

function! s:goyo_enter()
  lua require('lualine').hide()
  set linebreak
  
  " prevent double quit in Goyo
  let b:quitting = 0
  let b:quitting_bang = 0
  autocmd QuitPre <buffer> let b:quitting = 1
  cabbrev <buffer> q! let b:quitting_bang = 1 <bar> q!

  set conceallevel=0 "do not hide quotes in markdown
  " set mouse=
  set noshowmode " hide --INSERT-- at bottom

  if exists('g:did_coc_loaded')
    silent! CocDisable
    let b:coc_disabled = 1  " Track we disabled it
  endif

  " clear messages automatically
  augroup cmdline
    autocmd!
    autocmd CmdlineLeave : lua vim.defer_fn(function() vim.cmd('echo ""') end, 5000)
  augroup END
  
  set spell

endfunction

function! s:goyo_leave()
  lua require('lualine').hide({unhide=true})
  set nolinebreak
  CocStart
  set showmode

  " Quit Vim if this is the only remaining buffer
  if b:quitting && len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) == 1
    if b:quitting_bang
      qa!
    else
      qa
    endif
  endif

  " Re-enable Coc if we disabled it
  if exists('b:coc_disabled') && b:coc_disabled
    silent! CocEnable
  endif

  set nospell
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()

autocmd FileType markdown,rmd call SetupMarkdown()
function! SetupMarkdown()
  Goyo
  " call s:goyo_enter()
  call timer_start(50, {-> s:goyo_enter()})
endfunction

au FileType * if exists('$LOCAL_VIMRC') | call LoadLvimrc() | endif

function LoadLvimrc()
    let b:localrc_files = get(b:, 'localrc_files', [])
    let b:localrc_loaded = get(b:, 'localrc_loaded', 0)
    let l:lvimrcs = $LOCAL_VIMRC
    if empty(l:lvimrcs) | return | endif
    for l:file in split(l:lvimrcs, ':')
        if index(b:localrc_files, l:file) == -1
            source `=l:file`
            let b:localrc_loaded += 1
            let b:localrc_files += [l:file]
        endif
    endfor
endfunction

let g:vim_markdown_folding_disabled = 1

let g:plantuml_previewer#viewer_path = "~/tmp/plantuml"

" Enter key for auto completion
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"

let g:ditto_dir = "~/.cache/ditto"
